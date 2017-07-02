const path = require('path');
const { test } = require('tap');
const { run, extractBody, initServer } = require('./utils.js');

const PORT = 3000;

test('trigger', async t => {
  t.plan(3);

  let server = await initServer(PORT, async (req, res) => {
    const { method, url } = req;

    t.equal(url, '/repo/test%2Ftest/requests');
    t.equal(method, 'POST');
    res.end();
  });

  try {
    let out = await run(`trigger.sh test/test`, {
      env: {
        TRAVIS_API_ADDRESS: `http://localhost:${PORT}`,
        TRAVIS_ACCESS_TOKEN: 'travis-access-token',
        TRAVIS_BUILD_ID: 'build-ig',
        TRAVIS_REPO_SLUG: 'repo/slug',
      },
      shell: true,
      cwd: path.join(__dirname, '..'),
    });

    t.pass('execution worked');
  } catch (err) {
    t.error(err);
  }

  server.close();
  t.end();
});
