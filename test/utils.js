const http = require('http');
const { spawn } = require('child_process');

/**
 * Wraps HTTP server initialization with Promise.
 */
function initServer(port, handler) {
  let server = http.createServer(handler);

  return new Promise((res, rej) => server.listen(port, res.bind(null, server)));
}

/**
 * Executes a command and captures its stdout/stderr to
 * a variable (returned in the promise.
 */
function run(command, opts) {
  const args = command.split(' ');
  const proc = spawn(args.shift(), args, opts);

  let result = '';

  return new Promise((resolve, reject) => {
    proc.stdout.on('data', d => (result += d.toString()));
    proc.stderr.on('data', d => (result += d.toString()));
    proc.on('close', code => {
      if (!code) {
        return resolve(result);
      }
      reject(new Error(`Execution failed with code ${code} - data: ${result}`));
    });
  });
}

module.exports = {
  run,
  initServer,
};
