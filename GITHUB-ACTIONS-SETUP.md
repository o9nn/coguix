# GitHub Actions Setup for Coguix

## Overview

This document describes the GitHub Actions CI/CD pipeline for the Coguix project (GNU Guix fork with AI assistant features).

## Workflow: `guix-build.yml`

The main workflow file is located at `.github/workflows/guix-build.yml` and provides comprehensive build, test, and validation for the Guix system and AI assistant features.

### Workflow Structure

The workflow consists of the following jobs:

#### 1. **syntax-check**
- **Purpose**: Validate Scheme syntax and code style
- **Actions**:
  - Checks all `.scm` files for syntax errors
  - Scans for hardcoded paths (`/usr/`, `/opt/`)
  - Checks for trailing whitespace
- **Runtime**: ~2-3 minutes

#### 2. **build-guix**
- **Purpose**: Build the Guix system from source
- **Actions**:
  - Installs all build dependencies (Guile, autotools, etc.)
  - Runs `./bootstrap` to generate build scripts
  - Configures the build system
  - Compiles Guix with parallel builds
- **Matrix**: Tests with Guile 3.0
- **Runtime**: ~10-20 minutes
- **Dependencies**: Requires `syntax-check` to pass

#### 3. **test-packages**
- **Purpose**: Validate package definitions
- **Actions**:
  - Loads and validates package modules
  - Counts total packages
  - Checks module imports
- **Runtime**: ~2-3 minutes
- **Dependencies**: Requires `syntax-check` to pass

#### 4. **test-ai-assistant**
- **Purpose**: Test the AI assistant module
- **Actions**:
  - Validates AI assistant Scheme module syntax
  - Tests CLI interface
  - Checks for API integration
- **Runtime**: ~1-2 minutes
- **Dependencies**: Requires `syntax-check` to pass

#### 5. **build-opencog-packages**
- **Purpose**: Build OpenCog-related packages
- **Actions**:
  - Validates OpenCog package definitions
  - Prepares for package builds
- **Runtime**: ~5-10 minutes
- **Dependencies**: Requires `build-guix` to pass
- **Trigger**: Only on push or manual workflow dispatch

#### 6. **integration-test**
- **Purpose**: Run integration tests
- **Actions**:
  - Executes development tools scripts
  - Runs comprehensive validation
- **Runtime**: ~3-5 minutes
- **Dependencies**: Requires `build-guix` and `test-packages` to pass

#### 7. **documentation**
- **Purpose**: Build and validate documentation
- **Actions**:
  - Checks Texinfo documentation files
  - Validates README and guide files
- **Runtime**: ~1-2 minutes
- **Dependencies**: Requires `syntax-check` to pass

#### 8. **security-scan**
- **Purpose**: Security and quality scanning
- **Actions**:
  - Scans for potential secrets in code
  - Counts TODO/FIXME comments
- **Runtime**: ~1-2 minutes
- **Dependencies**: None (runs in parallel)

#### 9. **report**
- **Purpose**: Generate build report
- **Actions**:
  - Creates comprehensive build summary
  - Includes package statistics
  - Uploads report as artifact
- **Runtime**: ~1 minute
- **Dependencies**: Requires all main jobs to complete
- **Trigger**: Always runs (even if previous jobs fail)

#### 10. **notify-completion**
- **Purpose**: Notify build completion
- **Actions**:
  - Displays final build status
- **Runtime**: <1 minute
- **Dependencies**: Requires all main jobs to complete
- **Trigger**: Always runs

## Triggers

The workflow is triggered by:

1. **Push** to branches:
   - `master`
   - `feature/*`
   - `develop`

2. **Pull Request** to:
   - `master`

3. **Manual Dispatch**:
   - Via GitHub Actions UI

## Environment Variables

- `GUILE_LOAD_COMPILED_PATH`: Set to empty to avoid conflicts
- `GUIX_LOCPATH`: Set to empty for clean environment

## Required Secrets

For full AI assistant functionality, set the following repository secret:

- `OPENAI_API_KEY`: OpenAI API key for AI features (optional)

**Note**: The AI assistant will work in fallback mode without the API key, but with limited functionality.

## Artifacts

The workflow produces the following artifacts:

- **build-report**: Markdown report with build summary and statistics

## Expected Runtime

- **Total workflow time**: 15-30 minutes (depending on parallel execution)
- **Fastest path** (all checks pass): ~15 minutes
- **With failures**: May take longer due to retries

## Success Criteria

The workflow is considered successful when:

1. ✅ All Scheme syntax is valid
2. ✅ Guix builds successfully from source
3. ✅ Package definitions are valid
4. ✅ AI assistant module loads without errors
5. ✅ Integration tests pass
6. ✅ Documentation is valid
7. ✅ No critical security issues found

## Failure Handling

If a job fails:

1. **Check the job logs** in GitHub Actions UI
2. **Review the specific error messages**
3. **Fix the issues locally** and test with:
   ```bash
   ./scripts/dev-tools.sh all
   ```
4. **Push the fixes** - workflow will re-run automatically

## Local Testing

Before pushing, test locally:

```bash
# Check syntax
./scripts/dev-tools.sh syntax

# Validate packages
./scripts/dev-tools.sh validate

# Run all checks
./scripts/dev-tools.sh all

# Test AI assistant (if Guile is installed)
guile -L .secret-feature -c "(use-modules (guix ai-assistant))"
```

## Optimization Tips

1. **Parallel builds**: The workflow uses `make -j$(nproc)` for faster compilation
2. **Caching**: Consider adding caching for dependencies (future enhancement)
3. **Matrix strategy**: Currently tests with Guile 3.0, can be expanded
4. **Conditional jobs**: Some jobs only run on specific triggers to save resources

## Monitoring

Monitor the workflow:

1. **GitHub Actions tab**: View all workflow runs
2. **Status badges**: Add to README for visibility
3. **Email notifications**: Configure in GitHub settings
4. **Slack/Discord**: Set up webhooks for team notifications (future enhancement)

## Future Enhancements

Planned improvements:

- [ ] Add caching for build dependencies
- [ ] Expand Guile version matrix (3.0, 3.2)
- [ ] Add actual package build tests (requires Guix daemon)
- [ ] Implement automated package updates
- [ ] Add performance benchmarking
- [ ] Create release automation
- [ ] Add deployment to build farm

## Troubleshooting

### Common Issues

**Issue**: `guile: command not found`
- **Solution**: Ensure Guile is installed in the build environment

**Issue**: `Module (guix packages) not found`
- **Solution**: Check that Guix modules are properly compiled

**Issue**: `AI assistant module fails to load`
- **Solution**: Verify the module path and syntax

**Issue**: `Build takes too long`
- **Solution**: Check for inefficient build steps, consider caching

### Getting Help

- **IRC**: #guix on irc.libera.chat
- **Mailing List**: guix-devel@gnu.org
- **Issues**: https://github.com/cogpy/coguix/issues

## Contributing

When contributing:

1. Ensure your changes pass all workflow checks
2. Add tests for new features
3. Update documentation as needed
4. Follow the commit message format in `CONTRIBUTING-CICD.md`

## License

This workflow configuration is part of GNU Guix and is licensed under GPLv3+.

---

**Last Updated**: 2025-11-09
**Maintainer**: Manus AI / Coguix Team
