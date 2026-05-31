# Design

Figma design: https://www.figma.com/design/eLY9H4h1aKQrDZg7XmPIHE/To-do-list-project?node-id=2-3&t=Fy2LShduijHFx3Si-0

## Foundations

### Colors

The palette is monochromatic:

- Custom black: `#1E1E1E`
- White: `#FFFFFF`
- Error color: `#CC3D3D`

### Borders

- Standard border width: `4px`
- Standard border color: custom black `#1E1E1E`
- Main page container border radius: `18px`
- Input border radius: `36px`
- Error container border radius: `36px`

### Typography

The intended font is Inter. For now, the application uses the browser/system font stack. We may revisit the Inter font later.

#### Main title

```css
font-style: normal;
font-weight: 700;
font-size: 48px;
line-height: 58px;
text-align: center;
color: #FFFFFF;
vertical-align: middle;
```

#### Body text

```css
font-weight: 400;
font-style: Regular;
font-size: 32px;
leading-trim: NONE;
line-height: 100%;
letter-spacing: 0%;
text-align: center;
vertical-align: middle;
color: #1E1E1E;
```

#### Task text

```css
font-weight: 400;
font-style: Regular;
font-size: 32px;
leading-trim: NONE;
line-height: 100%;
letter-spacing: 0%;
vertical-align: middle;
color: #1E1E1E;
```

#### Placeholder helper text

```css
font-weight: 400;
font-style: Regular;
font-size: 32px;
leading-trim: NONE;
line-height: 100%;
letter-spacing: 0%;
text-align: left;
vertical-align: middle;
color: #1E1E1ECC;
```

The placeholder helper text should have breathing space on the left.

## Shared layout standards

Every page should use a centered main container.

The main container should have:

- `18px` border radius
- `4px` custom black border
- A custom black header
- A centered white title

## Error states

Errors should appear as a closable overlay anchored to the bottom of the viewport.

The overlay should:

- Be fixed to the bottom of the screen
- Span the available viewport width
- Center the error container horizontally
- Include comfortable viewport padding

The error container should have:

- White background
- Error color `#CC3D3D` for text, border, and close control
- `4px` border
- `36px` border radius
- A close button in the top-right corner

## Inputs

Inputs should have:

- `36px` border radius
- `4px` custom black border
- Placeholder helper text inside
- Left padding/breathing space for the placeholder

When an add button is paired with an input, the button should be aligned to the right inside the input area.

Form actions should provide Turbo submit feedback where applicable:

- Add list/task: `Adding…`
- Toggle task completion: `Saving…`
- Delete list/task: `Deleting…`
- Complete all tasks: `Completing…`

## Assets

The current logo/icon assets come from `tmp/images/` and are used as visual references/assets:

- `button.png` — add button
- `checked.png` — checked/completed task icon
- `delete.png` — delete button
- `no-tasks-page.png` — no-task page reference
- `todo-list-error.png` — error state reference
- `todo-list-page.png` — todo list page reference

In the Rails app, the interactive icons are copied into `app/assets/images/`.

## Scrollable item lists

Todo/task item lists should show about six rows at a time. When there are more items than fit in that area, the list itself should scroll vertically instead of growing the whole panel indefinitely.

## Todo list edit page

The todo list edit page follows the shared main container standard.

### Header

- The main title is the name of the todo list.
- For now, the title cannot be changed.
- The header uses the with-action layout when task completion controls are present:
  - Center the title and the action together.
  - Align items vertically in the center.
  - Use `20px` spacing between the title and the action.
- A complete-all action appears next to the title.
- The complete-all action sits inside a white circular background that is slightly larger than the action button.
- The white circular background is `60px` in diameter.
- The complete-all action uses a `48px` square completion button centered inside the white circle.
- When there are incomplete tasks, the action shows an unchecked custom-black circle and can be submitted to mark every task in the list complete.
- When all persisted tasks are complete, the action shows the checked icon, uses the checked completion state, and is disabled.
- After a new task is added with Turbo Streams, the complete-all action should be replaced so its checked/unchecked and disabled state stays current without a full-page refresh.

### Add task input

The body contains an input with placeholder text:

> Add your task…

The add button is placed in the leading/action position inside the input and aligned perfectly to the right.

### Empty state

If there are no tasks, show body text:

> No tasks have been entered yet

### Task items

If tasks exist, display task items.

Each task item has:

- A leading circle with `48px` diameter
- A custom black border around the leading circle
- `20px` spacing between the leading circle and the task text
- Task text using the task text typography
- A delete button aligned to the right

If the task is completed:

- The task text should use strikethrough
- The checked icon should be displayed

## Todo list index page

The todo list index page follows the same visual style as the edit page.

It should support:

- Adding a todo list by entering only the list name
- Listing existing todo lists
- Showing a no-lists caption when there are no lists
- Clicking a list to navigate to its edit page
- Destroying lists directly from the index page
