local PipelineDocs = {
  kind: 'pipeline',
  name: 'docs',
  platform: {
    os: 'linux',
    arch: 'amd64',
  },
  concurrency: {
    limit: 1,
  },
  steps: [
    {
      name: 'assets',
      image: 'thegeeklab/alpine-tools',
      commands: [
        'make doc',
      ],
    },
    {
      name: 'sync',
      image: 'thegeeklab/git-batch',
      commands: [
        'git-batch',
      ],
    },
    {
      name: 'markdownlint',
      image: 'thegeeklab/markdownlint-cli',
      commands: [
        "markdownlint 'docs/content/**/*.md' 'README.md' 'CONTRIBUTING.md'",
      ],
    },
    {
      name: 'spellcheck',
      image: 'node:lts-alpine',
      commands: [
        'npm install -g spellchecker-cli',
        "spellchecker --files 'docs/content/**/*.md' 'README.md' -d .dictionary -p spell indefinite-article syntax-urls --no-suggestions",
      ],
      environment: {
        FORCE_COLOR: true,
        NPM_CONFIG_LOGLEVEL: 'error',
      },
    },
    {
      name: 'testbuild',
      image: 'thegeeklab/hugo:0.83.1',
      commands: [
        'hugo -s docs/ -b http://localhost/',
      ],
    },
    {
      name: 'link-validation',
      image: 'thegeeklab/link-validator',
      commands: [
        'link-validator -ro',
      ],
      environment: {
        LINK_VALIDATOR_BASE_DIR: 'docs/public',
      },
    },
    {
      name: 'build',
      image: 'thegeeklab/hugo:0.83.1',
      commands: [
        'hugo -s docs/',
      ],
    },
    {
      name: 'beautify',
      image: 'node:lts-alpine',
      commands: [
        'npm install -g js-beautify',
        "html-beautify -r -f 'docs/public/**/*.html'",
      ],
      environment: {
        FORCE_COLOR: true,
        NPM_CONFIG_LOGLEVEL: 'error',
      },
    },
    {
      name: 'publish',
      image: 'plugins/s3-sync',
      settings: {
        access_key: { from_secret: 's3_access_key' },
        bucket: 'geekdocs',
        delete: true,
        endpoint: 'https://sp.rknet.org',
        path_style: true,
        secret_key: { from_secret: 's3_secret_access_key' },
        source: 'docs/public/',
        strip_prefix: 'docs/public/',
        target: '/${DRONE_REPO_NAME}',
      },
      when: {
        ref: ['refs/heads/main', 'refs/tags/**'],
      },
    },
  ],
  trigger: {
    ref: ['refs/heads/main', 'refs/tags/**', 'refs/pull/**'],
  },
};

[
  PipelineDocs,
]
