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
        "markdownlint 'content/**/*.md' 'README.md' 'CONTRIBUTING.md'",
      ],
    },
    {
      name: 'spellcheck',
      image: 'thegeeklab/alpine-tools',
      commands: [
        "spellchecker --files 'content/**/*.md' 'README.md' -d .dictionary -p spell indefinite-article syntax-urls --no-suggestions",
      ],
      environment: {
        FORCE_COLOR: true,
        NPM_CONFIG_LOGLEVEL: 'error',
      },
    },
    {
      name: 'testbuild',
      image: 'thegeeklab/hugo:0.97.3',
      commands: [
        'hugo --panicOnWarning -b http://localhost:8000/',
      ],
    },
    {
      name: 'link-validation',
      image: 'thegeeklab/link-validator',
      commands: [
        'link-validator --color=always',
      ],
      environment: {
        LINK_VALIDATOR_BASE_DIR: 'public',
        LINK_VALIDATOR_RETRIES: '3',
      },
    },
    {
      name: 'build',
      image: 'thegeeklab/hugo:0.97.3',
      commands: [
        'hugo --panicOnWarning',
      ],
    },
    {
      name: 'beautify',
      image: 'thegeeklab/alpine-tools',
      commands: [
        "html-beautify -r -f 'public/**/*.html'",
      ],
      environment: {
        FORCE_COLOR: true,
        NPM_CONFIG_LOGLEVEL: 'error',
      },
    },
    {
      name: 'publish',
      image: 'thegeeklab/drone-s3-sync',
      settings: {
        access_key: { from_secret: 's3_access_key' },
        bucket: 'geekdocs',
        delete: true,
        endpoint: 'https://sp.rknet.org',
        path_style: true,
        secret_key: { from_secret: 's3_secret_access_key' },
        source: 'public/',
        strip_prefix: 'public/',
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
