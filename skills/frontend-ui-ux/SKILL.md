# Skill: Frontend UI/UX

**Trigger:** "design", "UI", "style", "layout", "CSS", "responsive", "animation", "component", "frontend", "redesign", or any visual/frontend task.

## Purpose

Design-first frontend development. Crafts stunning UI/UX even without design mockups. Follows modern design principles and accessibility standards.

## Design Process

### Phase 1: Assess
1. Understand the user need and context
2. Identify existing design patterns in the project
3. Determine the visual hierarchy and layout requirements
4. Note accessibility requirements (WCAG 2.1 AA minimum)

### Phase 2: Design
1. **Layout** — Grid systems, spacing scale, responsive breakpoints
2. **Typography** — Font scale, line height, readability
3. **Color** — Primary/secondary palette, contrast ratios, dark mode
4. **Components** — Reusable, consistent, accessible
5. **Animation** — Purposeful, performant (prefers-reduced-motion)

### Phase 3: Implement
1. Use existing CSS framework/patterns if present
2. If no framework, apply modern CSS (custom properties, grid, flexbox)
3. Mobile-first responsive design
4. Semantic HTML with ARIA attributes where needed
5. Test at multiple viewport sizes

### Phase 4: Verify
1. Check color contrast ratios (4.5:1 minimum for normal text)
2. Verify keyboard navigation works
3. Test with screen reader considerations
4. Check performance (no layout shift, fast paint)

## CSS Conventions

- Use CSS custom properties for theming
- Mobile-first media queries
- BEM or project-specific naming convention
- No inline styles except for dynamic values
- Use `rem` for spacing, `em` for component-relative sizing

## Anti-Patterns (NEVER)

- !important unless absolutely necessary
- Inline styles for static properties
- Fixed pixel widths for responsive layouts
- Hardcoded colors without CSS variable references
- Animations without prefers-reduced-motion check
- Non-semantic HTML (divs for buttons, spans for headings)
