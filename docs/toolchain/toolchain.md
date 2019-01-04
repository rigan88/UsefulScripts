# Toolchain

## Overview

- <https://docs.microsoft.com/en-us/sharepoint/dev/spfx/toolchain/sharepoint-framework-toolchain>
- <https://github.com/SharePoint/sp-dev-docs/blob/master/docs/spfx/tools-and-libraries.md>

## Prepare

- [Preparing development machine for client-side SharePoint projects](https://www.linkedin.com/pulse/preparing-development-machine-client-side-sharepoint-mac-koltyakov)

## Gulp

- <https://www.eliostruyf.com/getting-up-to-speed-with-gulp/>
- <https://medium.com/@baranovskyyoleg/gulp-basic-usage-7afc460119f0>
- <https://thomasdaly.net/2018/08/12/spfx-automatically-generating-revision-numbers/>
- <https://thomasdaly.net/2018/08/21/update-spfx-automatically-generating-revision-numbers-versioning/>

### Deployment

- <https://github.com/estruyf/UploadToOffice365SPFx/blob/master/gulpfile.js>
- <https://github.com/estruyf/gulp-spsync-creds>
- <https://n8d.at/blog/how-to-version-new-sharepoint-framework-projects/?platform=hootsuite>

## NPM

### package-lock.json

- <https://medium.com/coinmonks/everything-you-wanted-to-know-about-package-lock-json-b81911aa8ab8>

### Optimization packages

- <https://docs.microsoft.com/en-us/sharepoint/dev/spfx/toolchain/optimize-builds-for-production>
- <https://docs.microsoft.com/en-us/sharepoint/dev/spfx/toolchain/optimize-builds-for-production>
- https://rencore.com/sharepoint-framework/script-check/
- <https://www.techmikael.com/2018/08/an-adventure-into-optimizing-sharepoint.html>

### Update packages

- https://gist.github.com/iki/ec32bfdeeb23930efd15

```bash
# check
npm outdated -g

# install
npm -g i npm-check

# interactive update of global packages
npm-check -u -g

# interactive update for a project you are working on
npm-check -u

# unistall package
npm uninstall -g <module>
```

### Check package version

- https://github.com/dylang/npm-check

List global npm  packages versions

```bash
npm list -g --depth 0
```

List detail global npm  package versions from one package

```bash
npm view @microsoft/generator-sharepoint
```