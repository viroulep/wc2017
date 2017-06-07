json.array! @groups, partial: 'groups/group', as: :group
json.array! @staff_registrations_groups, partial: 'groups/group', as: :group, locals: { staff: true }
json.array! @staff_groups, partial: 'groups/group', as: :group, locals: { staff: true }
