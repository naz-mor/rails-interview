# Demo data for local development and client walkthroughs.
# Creates enough todo lists and todo items to exercise the default 10-item pagination.

TodoItem.delete_all
TodoList.delete_all

workflows = {
  'Client onboarding launch plan' => [
    ['Confirm kickoff agenda', true],
    ['Collect stakeholder contact list', true],
    ['Send welcome email', true],
    ['Schedule discovery workshop', false],
    ['Document success metrics', false],
    ['Prepare implementation timeline', false],
    ['Review security requirements', false],
    ['Create shared project folder', false],
    ['Assign internal owner', false],
    ['Draft weekly status template', false],
    ['Book executive check-in', false],
    ['Publish launch checklist', false],
    ['Confirm go-live support window', false],
    ['Prepare training deck', false],
    ['Collect post-launch feedback', false]
  ],
  'Website refresh' => [
    ['Audit current landing page', true],
    ['Pick hero copy', true],
    ['Update product screenshots', false],
    ['Review responsive layouts', false],
    ['Publish staging preview', false],
    ['Run accessibility pass', false],
    ['Coordinate launch announcement', false],
    ['Measure conversion impact', false],
    ['Archive old assets', false],
    ['Prepare rollback plan', false],
    ['QA contact form', false],
    ['Update SEO metadata', false]
  ],
  'Quarterly planning' => [
    ['Review last quarter goals', true],
    ['Collect team proposals', true],
    ['Prioritize roadmap themes', false],
    ['Estimate budget needs', false],
    ['Share draft plan', false],
    ['Finalize quarterly milestones', false],
    ['Create reporting dashboard', false],
    ['Schedule monthly reviews', false],
    ['Align hiring needs', false],
    ['Publish final plan', false],
    ['Create risk register', false]
  ]
}

workflows.each do |list_name, items|
  todo_list = TodoList.create!(name: list_name)

  items.each do |item_name, completed|
    todo_list.todo_items.create!(name: item_name, completed: completed)
  end
end

additional_lists = [
  'Sales follow-up queue',
  'Support escalations',
  'Product discovery notes',
  'Marketing campaign checklist',
  'Finance close tasks',
  'Operations improvements',
  'Engineering maintenance',
  'Hiring pipeline',
  'Customer success renewals',
  'Security review backlog',
  'Data migration plan',
  'Release readiness',
  'Training materials',
  'Partner enablement',
  'Office move checklist',
  'Legal review items',
  'Analytics cleanup',
  'Internal communications',
  'Vendor evaluation',
  'Board meeting prep',
  'API integration rollout',
  'Mobile app polish'
]

additional_lists.each_with_index do |list_name, index|
  todo_list = TodoList.create!(name: list_name)

  3.times do |item_index|
    todo_list.todo_items.create!(
      name: "#{list_name} task #{item_index + 1}",
      completed: item_index.zero? && index.even?
    )
  end
end
