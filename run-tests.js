// Test runner for all samples.
// 
// node run-tests.js <dir1> <dir2>
// 
//  Will only load/run the samples in the given directories.
//
// node run-tests.js
//
//  Will load/run the samples in all sub-directories.
//
// The runner will compile all .wat files to .wasm with wat2wasm (which has
// to be installed and available in PATH!), and will then run the test.js
// test file in each directory it loads.
'use strict';

const fs = require('node:fs');
const path = require('node:path');
const { spawnSync } = require('node:child_process');

// Entry point: builds the directory list, parses CLI filters, then
// dispatches each selected test directory through the build+run loop.
function main() {
  const rootDir = __dirname;
  const entries = fs.readdirSync(rootDir, { withFileTypes: true });
  const allDirs = entries
    .filter((entry) => entry.isDirectory() && !entry.name.startsWith('_') && !entry.name.startsWith('.'))
    .map((entry) => entry.name)
    .sort();

  if (allDirs.length === 0) {
    console.log('No test directories found.');
    return;
  }

  // Collect command-line filters; maintain deduplication (`seen`) so the
  // same test isn't executed twice, and accumulate overall results for
  // the final summary.
  const requested = process.argv.slice(2);
  const available = new Set(allDirs);
  const queue = [];
  const seen = new Set();
  const results = [];

  if (requested.length > 0) {
    for (const name of requested) {
      if (seen.has(name)) {
        continue;
      }
      seen.add(name);
      if (!available.has(name)) {
        results.push({ name, status: 'SKIP', message: 'Test directory not found.' });
        continue;
      }
      queue.push(name);
    }
  } else {
    queue.push(...allDirs);
  }

  if (queue.length === 0 && results.length > 0) {
    // All requested tests were missing; still print the summary.
    printSummary(results);
    return;
  }

  // Iterate each selected directory, making sure required inputs exist,
  // compiling all .wat files we find, and recording the outcome.
  sampleloop: for (const dirName of queue) {
    const dirPath = path.join(rootDir, dirName);
    const testScript = path.join(dirPath, 'test.js');
    if (!fs.existsSync(testScript)) {
      results.push({ name: dirName, status: 'SKIP', message: 'No test.js found.' });
      continue;
    }

    const watFiles = fs.readdirSync(dirPath).filter((name) => name.endsWith('.wat'));

    if (watFiles.length === 0) {
      results.push({ name: dirName, status: 'FAIL', message: 'No .wat files found.' });
      continue;
    }

    // Compile each .wat to a sibling .wasm; abort the suite on the first
    // failure so we don't attempt to run an incomplete build.
    for (const watFile of watFiles) {
      const wasmFile = watFile.replace(/\.wat$/i, '.wasm');
      console.log(`\n[${dirName}] Building ${watFile} -> ${wasmFile}`);
      const buildResult = runCommand('wat2wasm', ['--enable-all', watFile, '-o', wasmFile], dirPath);
      if (!buildResult.ok) {
        results.push({ name: dirName, status: 'FAIL', message: `wat2wasm ${watFile}: ${buildResult.message}` });
        continue sampleloop;
      }
    }

    console.log(`[${dirName}] Running test.js`);

    const testResult = runCommand(process.execPath, ['test.js'], dirPath);
    if (testResult.ok) {
      results.push({ name: dirName, status: 'PASS' });
    } else {
      results.push({ name: dirName, status: 'FAIL', message: `test.js: ${testResult.message}` });
    }
  }

  printSummary(results);
}

// Spawn helper that runs the desired command synchronously in a subdirectory
// and reports success/failure with context.
function runCommand(command, args, cwd) {
  const result = spawnSync(command, args, { cwd, stdio: 'inherit' });

  if (result.error) {
    return { ok: false, message: `Failed to start ${command}: ${result.error.message}` };
  }

  if (result.status !== 0) {
    if (result.status === null) {
      return { ok: false, message: `${command} exited due to signal ${result.signal}.` };
    }
    return { ok: false, message: `${command} exited with code ${result.status}.` };
  }

  return { ok: true };
}

try {
  main();
} catch (err) {
  console.error('Unexpected error:', err);
  process.exitCode = 1;
}

// After all suites have been processed, format the PASS/FAIL/SKIP table
// and set the overall process status.
function printSummary(results) {
  const failed = results.filter((result) => result.status === 'FAIL');

  console.log('\nTest summary:');
  for (const result of results) {
    if (result.status === 'PASS') {
      console.log(`  PASS ${result.name}`);
    } else if (result.status === 'SKIP') {
      console.log(`  SKIP ${result.name}: ${result.message}`);
    } else {
      console.log(`  FAIL ${result.name}: ${result.message}`);
    }
  }

  if (failed.length > 0) {
    console.error(`\n${failed.length} test(s) failed.`);
    process.exitCode = 1;
  } else {
    console.log('\nAll tests passed.');
  }
}
