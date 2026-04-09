---
name: ai-slop-remover
description: Remove AI-generated code smells and patterns from code. Use when cleaning up AI-generated code, removing over-commenting, simplifying verbose patterns, or making code look like a senior engineer wrote it.
---

# AI Slop Remover

**Trigger:** "clean up AI code", "remove AI slop", "make this look human", "review for AI patterns", or after AI-generated code needs polishing.

## Purpose

Removes AI-generated code smells from code while preserving functionality. Makes code read like a senior engineer wrote it.

## AI Slop Patterns to Detect and Remove

### Over-Commenting
```javascript
// BAD: AI slop
// This function calculates the total price
// It takes the items array and returns the sum
function calculateTotal(items) {
  // Initialize total to zero
  let total = 0;
  // Loop through each item
  for (const item of items) {
    // Add the item price to total
    total += item.price;
  }
  // Return the total
  return total;
}

// GOOD: Senior engineer code
function calculateTotal(items) {
  return items.reduce((sum, item) => sum + item.price, 0);
}
```

### Unnecessary Abstractions
```javascript
// BAD: AI over-engineering
class UserService {
  constructor(userRepository) {
    this.userRepository = userRepository;
  }
  async getUserById(id) {
    return await this.userRepository.findById(id);
  }
}

// GOOD: Direct and simple
const getUserById = (id) => userRepository.findById(id);
```

### Verbose Error Messages
```javascript
// BAD: AI explaining the obvious
catch (error) {
  console.error("An error occurred while attempting to fetch the user data from the database. This could be due to network issues, database connectivity problems, or invalid query parameters.");
}

// GOOD: Specific and actionable
catch (error) {
  logger.error("Failed to fetch user", { userId, error: error.message });
}
```

### Redundant Type Annotations
```typescript
// BAD: AI over-typing
const name: string = "John";
const count: number = 0;
const isValid: boolean = true;

// GOOD: Let TypeScript infer
const name = "John";
const count = 0;
const isValid = true;
```

### Empty/Useless Functions
```javascript
// BAD: AI placeholder
function handleUserInput(input) {
  // TODO: implement
  // For now, just return the input
  return input;
}

// GOOD: Either implement properly or don't create the function yet
```

## Cleanup Process

### Step 1: Identify
Scan the file for AI slop patterns listed above.

### Step 2: Remove
- Delete redundant comments that explain obvious code
- Simplify over-engineered abstractions
- Consolidate verbose patterns
- Remove TODO placeholders that should have been implemented

### Step 3: Polish
- Ensure code follows project conventions
- Add comments ONLY for non-obvious logic
- Verify functionality is preserved
- Run tests if available

## Rules

- NEVER change functionality — only improve readability
- NEVER remove genuinely useful comments
- ALWAYS preserve the file's existing style
- ALWAYS verify the code still works after cleanup
