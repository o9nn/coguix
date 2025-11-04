# Contributing to Guix - CI/CD Guide

Welcome to the Guix project! This guide will help you understand our CI/CD system and how to work with it effectively.

## 🎯 Quick Start

### Before You Commit

Run the development tools to check your changes:

```bash
./scripts/dev-tools.sh all
```

This will:
- ✅ Check Scheme syntax
- ✅ Validate package definitions
- ✅ Run quick tests
- ✅ Check for common issues

### Making a Pull Request

1. **Fork and clone** the repository
2. **Create a branch** with a descriptive name
3. **Make your changes** following our guidelines
4. **Run local checks** using dev-tools.sh
5. **Commit** with proper format: `module: description`
6. **Push** to your fork
7. **Create PR** with appropriate title prefix

### PR Title Format

Use one of these prefixes:

- `gnu:` - Package definitions in gnu/packages/
- `guix:` - Core Guix modules
- `services:` - System services
- `doc:` - Documentation changes
- `tests:` - Test additions/modifications
- `build:` - Build system changes
- `ci:` - CI/CD improvements

**Examples:**
- `gnu: Add python-awesome-package`
- `guix: Fix bug in package resolution`
- `services: Update nginx service configuration`
- `doc: Improve installation instructions`

## 🔄 CI/CD Workflow

### What Happens When You Submit a PR?

1. **Automated Analysis** (< 1 minute)
   - PR metadata validation
   - Changed files analysis
   - Automated comment with recommendations

2. **Syntax and Validation** (2-5 minutes)
   - Scheme syntax checking
   - Package definition validation
   - Commit message format check

3. **Build and Test** (10-30 minutes)
   - Build with multiple Guile versions
   - Run test suite
   - Integration tests

4. **Security and Quality** (5-10 minutes)
   - Security vulnerability scan
   - Code quality checks
   - Documentation build

5. **Performance** (2-5 minutes)
   - Performance benchmarks
   - Resource usage analysis

### Understanding CI Results

#### ✅ All Checks Passed
Your PR is ready for review! A maintainer will review it soon.

#### ⚠️ Some Checks Failed
Check the workflow logs to see what failed:
1. Click on "Details" next to the failed check
2. Review the error messages
3. Fix the issues locally
4. Push the fixes (CI will re-run automatically)

#### 🔄 Checks In Progress
Be patient! Some checks take time. You'll get notified when they complete.

## 📦 Package Contribution Guidelines

### Adding a New Package

1. **Create the package definition** in the appropriate file under `gnu/packages/`

2. **Include all required fields:**
   ```scheme
   (define-public my-package
     (package
       (name "my-package")
       (version "1.0.0")
       (source ...)
       (build-system ...)
       (synopsis "Short one-line description")
       (description "Longer description...")
       (home-page "https://example.com")
       (license license:gpl3+)))
   ```

3. **Test locally:**
   ```bash
   guix build my-package
   guix install my-package
   ```

4. **Run validation:**
   ```bash
   ./scripts/dev-tools.sh validate
   ```

5. **Update NEWS** if it's a significant package

### Updating an Existing Package

1. **Update version and hash:**
   ```scheme
   (version "1.1.0")
   (sha256
     (base32 "new-hash-here"))
   ```

2. **Test the build:**
   ```bash
   guix build package-name --no-grafts
   ```

3. **Check for dependents:**
   ```bash
   guix refresh -l package-name
   ```

4. **Update commit message:**
   ```
   gnu: Update package-name to 1.1.0.
   
   * gnu/packages/category.scm (package-name): Update to 1.1.0.
   ```

## 🧪 Testing

### Running Tests Locally

```bash
# Run all tests
make check

# Run specific test
make check TESTS=tests/packages.scm

# Run tests in parallel
make check -j$(nproc)
```

### Writing Tests

Add tests for new functionality in `tests/`:

```scheme
(test-begin "my-feature")

(test-assert "my-feature works"
  (my-feature-function))

(test-end)
```

## 🔍 Code Review Process

### What Reviewers Look For

1. **Code Quality**
   - Proper Scheme style
   - Clear variable names
   - Appropriate comments

2. **Package Quality**
   - All required fields present
   - Accurate description
   - Correct license
   - Working build

3. **Tests**
   - Adequate test coverage
   - Tests pass consistently

4. **Documentation**
   - Updated when needed
   - Clear and accurate

### Responding to Review Comments

1. **Make requested changes** in new commits
2. **Reply to comments** explaining your changes
3. **Push updates** (CI will re-run)
4. **Request re-review** when ready

## 🚀 Advanced Topics

### Cross-Compilation

Many build systems need cross-compilation support. Check for:

```scheme
;; TODO: support cross-compilation
```

Consider implementing cross-compilation support!

### Parallel Builds

Enable parallel builds when possible:

```scheme
#:parallel-build? #t
```

### Grafts

Understand grafts for security updates:

```bash
guix build --no-grafts package-name
```

## 📊 Monitoring Your Contributions

### Check CI Status

- **GitHub Actions tab**: See all workflow runs
- **PR checks**: Status of your PR's CI runs
- **Artifacts**: Download test results and logs

### Performance Impact

The CI system tracks performance. If your changes significantly impact performance, reviewers will discuss optimization strategies.

## 🐛 Troubleshooting

### "Syntax error in my package"

```bash
# Check syntax locally
guile --no-auto-compile -s gnu/packages/my-file.scm

# Use dev tools
./scripts/dev-tools.sh syntax
```

### "Build fails in CI but works locally"

- Check Guile version differences
- Verify all dependencies are declared
- Review CI logs for environment differences

### "Tests are flaky"

- Run tests multiple times locally
- Check for timing dependencies
- Consider making tests more deterministic

### "CI is taking too long"

- Some checks are slow by design
- You can continue working on other things
- Check if there's a backlog of CI jobs

## 🎓 Learning Resources

### Guix Documentation

- [Guix Manual](https://guix.gnu.org/manual/)
- [Cookbook](https://guix.gnu.org/cookbook/)
- [Contributing Guide](https://guix.gnu.org/manual/en/html_node/Contributing.html)

### Community

- **IRC**: #guix on irc.libera.chat
- **Mailing List**: guix-devel@gnu.org
- **Bug Tracker**: https://codeberg.org/guix/guix/issues/

### Code Style

- Follow existing code patterns
- Use proper indentation (2 spaces)
- Keep lines under 80 characters when reasonable
- Add comments for complex logic

## 🌟 Best Practices Summary

### ✅ DO

- Run local checks before pushing
- Write clear commit messages
- Include tests for new features
- Update documentation
- Respond to review comments promptly
- Ask questions when unsure

### ❌ DON'T

- Push without testing locally
- Ignore CI failures
- Submit huge PRs without discussion
- Copy code without understanding licenses
- Leave TODO comments without issues
- Force push after review starts

## 🎉 Recognition

Contributors are recognized in:
- Git commit history
- AUTHORS file
- Release announcements
- Community discussions

Thank you for contributing to Guix!

## 📞 Getting Help

Stuck? Need help?

1. **Check documentation** in this guide and the main manual
2. **Run dev tools** for automated diagnostics
3. **Ask on IRC** - friendly community ready to help
4. **Email the list** - guix-devel@gnu.org
5. **Search issues** - someone may have had the same problem

## 🔮 Future CI/CD Features

We're working on:

- Automated dependency updates
- Better performance profiling
- Enhanced security scanning
- Automated release management
- Integration with build farms

Want to help? Check the CI/CD issues or propose improvements!

---

**Happy Contributing! 🎊**

*Last updated: 2025-11-04*
