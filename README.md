<h1 align="center">travis-triggerer 👷  </h1>

<h5 align="center">A single drop-in script to trigger <a href="https://travis-ci.com/">travis-ci</a> builds from other builds.</h5>

<br/>


#### Quickstart


1. Configure Travis to include an access token via an environment variable called `TRAVIS_ACCESS_TOKEN`.

This is necessary in order to perform an authenticated request against the Travis API to trigger a build for a repository that you have permissions to activate builds for.
   
note.: This is doable either via right in your `.travis.yml` or using the `settings` tab of the repository in `travis-ci.com`. See https://docs.travis-ci.com/user/environment-variables/

To obtain a token you can use the Travis CLI:

  ```sh
  # install ruby & ruby gems, then install the cli
  gem install travis

  # for travis-ci.org
  travis login --org
  travis token --org

  # for travis-ci.com
  travis login --pro
  travis token --pro
  ```

2. Modify your `.travis.yml` file to include the script once the build succeeds.

For instance:

```yml
language: 'node_js'
node_js:
  - '8'
  
# After `script` has been successfully exited (i.e, my test/build
# finishes with success), execute the triggerer
after_succces:
  - './.travis/trigger-build.sh cirocosta/nfsvol'
```


See more about build customization at [travis-ci #customizing-the-build](https://docs.travis-ci.com/user/customizing-the-build).

#### FAQ

**Q**: Can I customize it?
**A**: Of course! This is just a little script following [travis-ci #triggering-builds](https://docs.travis-ci.com/user/triggering-builds/).


**Q**: How can I use it for the public offering of Travis (i.e, [travis-ci.org](https://travis-ci.org)?
**A**: Generate an API token for `org` and then, in the script, replace `.com` by `.org`.


**Q**: Can I customize the commit message?
**A**: Sure! Head to `trigger_build` in the script and change it there.

