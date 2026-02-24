# UI Testing

Best practices for testing React UI components. These rules ensure tests are meaningful, maintainable, and resilient to implementation changes.

## Rules

1. **Never use DOM traversal** — Do not use `container.querySelector`, `.parentElement`, `.children`, `.closest()`, or any DOM traversal API. These couple tests to internal DOM structure, making them brittle when markup changes.
2. **Semantic queries only** — Priority order: `getByRole` > `getByLabelText` > `getByText` > `getByTestId`. Prefer queries that reflect how users perceive the page.
3. **`getByTestId` is last resort** — Only use when no semantic query works. Pass `data-testid` as a prop in the test render call — never add it to component source code.
4. **`userEvent` over `fireEvent`** — `userEvent` simulates full user interactions (focus, pointer, keyboard). `fireEvent` dispatches isolated DOM events.
5. **`test.each` for similar cases** — Use parameterised tests rather than duplicating test bodies.

## User Interaction Setup

```tsx
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";

test("submits the form when clicking save", async () => {
  const user = userEvent.setup();
  const handleSave = vi.fn();

  render(<MyForm onSave={handleSave} />);

  await user.type(screen.getByRole("textbox", { name: /title/i }), "New title");
  await user.click(screen.getByRole("button", { name: /save/i }));

  expect(handleSave).toHaveBeenCalledWith("New title");
});
```

## Query Priority Examples

```tsx
// ✅ Best: getByRole (how the user perceives the element)
screen.getByRole("button", { name: /submit/i });
screen.getByRole("textbox", { name: /email/i });
screen.getByRole("heading", { level: 2 });

// ✅ Good: getByLabelText (for form elements)
screen.getByLabelText(/password/i);

// ✅ Acceptable: getByText (for non-interactive content)
screen.getByText(/no results found/i);

// ⚠️ Last resort: getByTestId
screen.getByTestId("complex-widget");
```

## Testing Patterns

### Async Operations

```tsx
import { render, screen, waitFor } from "@testing-library/react";

test("shows loading then results", async () => {
  render(<DataList />);

  expect(screen.getByRole("progressbar")).toBeInTheDocument();

  await waitFor(() => {
    expect(screen.getByRole("table")).toBeInTheDocument();
  });
});
```

### Parameterised Tests

```tsx
test.each([
  { variant: "primary", label: "Submit" },
  { variant: "secondary", label: "Cancel" },
  { variant: "ghost", label: "Dismiss" },
])("renders $variant button with correct text", ({ variant, label }) => {
  render(<Button variant={variant}>{label}</Button>);
  expect(screen.getByRole("button", { name: label })).toBeInTheDocument();
});
```

### Testing Callbacks

```tsx
test("calls onSave with input value", async () => {
  const user = userEvent.setup();
  const handleSave = vi.fn();

  render(<EditForm onSave={handleSave} />);

  await user.type(screen.getByRole("textbox"), "new value");
  await user.click(screen.getByRole("button", { name: /save/i }));

  expect(handleSave).toHaveBeenCalledWith("new value");
  expect(handleSave).toHaveBeenCalledTimes(1);
});
```

### Testing Conditional Rendering

```tsx
test("shows error message when validation fails", async () => {
  const user = userEvent.setup();
  render(<LoginForm />);

  await user.click(screen.getByRole("button", { name: /sign in/i }));

  expect(screen.getByRole("alert")).toHaveTextContent(/email is required/i);
});
```

## What to Test

**Do test:**
- User-visible behaviour (what renders, what happens on interaction)
- Accessibility attributes (roles, labels, ARIA)
- Callback invocations (correct args, correct timing)
- Conditional rendering (show/hide based on props or state)
- Loading and error states

**Don't test:**
- Internal state values
- Implementation details (which hook was called, internal method names)
- CSS class names (unless critical to functionality)
- Third-party library internals
- Snapshot tests of entire components (too brittle)
