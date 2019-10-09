#!/usr/bin/env node

const exec = require('child_process').exec;

function promiseExec(command) {
  return new Promise((resolve) => {
    exec(command, (error, stdout, stderr) => {
      resolve({error, stdout, stderr});
    })
  });
}

// Note: Even though Timewarrior's date output format is 8601 compliant, it
//  needs to be tranformed before it can be parsed by JS Date.
// Ex: 20190730T161951Z -> 2019-07-30T16:19:51Z
const twRegex = /(\d\d\d\d)(\d\d)(\d\dT\d\d)(\d\d)(\d\dZ)/
function parseTWDate(twStr) {
  return new Date(twStr.replace(twRegex, "$1-$2-$3:$4:$5"));
}

function pad(n, width, z) {
  z = z || '0';
  n = n + '';
  return n.length >= width ? n : new Array(width - n.length + 1).join(z) + n;
}

function intersect(arr1, arr2) {
  return arr1
           .filter(e => arr2.includes(e))
           .filter((e, i, c) => c.indexOf(e) === i);
}

async function Main() {
  const output = [];
  const powerLineLeft = process.env.PL_LEFT || '│';
  const today = JSON.parse((await promiseExec('timew export today')).stdout);
  total = 0;
  let currentTags, currentDuration;
  for (const entry of today) {
    let isCurrent = false;
    let startDate = parseTWDate(entry.start);
    let endDate;
    if (entry.end) {
      endDate = parseTWDate(entry.end);
    } else {
      isCurrent = true;
      endDate = Date.now();
    }
    let entryDuration = endDate - startDate;
    if (isCurrent) {
      currentTags = Array.from(entry.tags);
      currentDuration = entryDuration;
    }
    total += entryDuration;
  }

  if (currentTags && currentTags.length > 0) {
    const excludedTags = ["code", "admin"];
    const seconds = Math.floor(currentDuration / 1000);
    const minutes = Math.floor(seconds / 60);
    if (intersect(excludedTags, currentTags).length == 0) {
      // Display specific time for less common timers
      output.push(`${currentTags[0]} ${minutes}:`);
      output.push(`${pad(seconds % 60, 2, 0)} ${powerLineLeft} `);
    }
  }

  if (total > 0) {
    // Total is now the number of tracked ms today
    const minutes = Math.floor(total / 60000);
    const hours = Math.floor(minutes / 60);
    output.push(`${hours}:${pad(minutes % 60, 2, 0)}`);
  }

  return output.join("");
}

Main()
  .then(output => {
    console.log(output);
    process.exit(0);
  })
  .catch(error => {
    console.log(error);
    process.exit(2);
  });
