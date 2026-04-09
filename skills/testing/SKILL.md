---
name: testing
description: Comprehensive test creation using TDD principles. Use when writing tests, improving coverage, fixing failing tests, or setting up test infrastructure.
---

# Testing

**Trigger:** Use when writing tests, improving coverage, fixing failing tests,
or setting up test infrastructure. Or when user says "test", "write tests",
"coverage", "TDD".

## Purpose

Comprehensive test creation using the `testing-expert` subagent. Follows
TDD principles with arrange-act-assert pattern.

## Testing Strategy

### 1. Identify What to Test
- Public API surfaces (highest priority)
- Complex business logic
- Edge cases and error handling
- Integration points between modules

### 2. Choose Test Types
| Type | When | Tool |
|------|------|------|
| Unit | Single function/class | Direct invocation |
| Integration | Multiple components | End-to-end flow |
| Property | Input/output invariants | Property-based testing |

### 3. Write Tests (Arrange-Act-Assert)
```
// Arrange: setup inputs, mocks, state
const input = ...;

// Act: call the function
const result = targetFunction(input);

// Assert: verify expected output
expect(result).toBe(expected);
```

### 4. Coverage Goals
- **Minimum:** 80% line coverage
- **Critical paths:** 100% branch coverage
- **Edge cases:** All error paths tested

## How to Run

```
Use the testing-expert subagent to write tests for [module/file]
```

## Test Conventions

- Follow project's existing test framework and style
- Test file location: match project convention (alongside or separate dir)
- Test naming: descriptive — "should [behavior] when [condition]"
- Mocks: only external dependencies, keep minimal
