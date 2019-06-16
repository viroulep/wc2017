Registration.includes(:groups, staff_registrations_groups: [:group], staff_teams_groups: [:group]).all.each do |r|
  last = nil
  replacements = StaffRegistrationsGroup.includes(:group).replacements_for(r.name).map(&:group).uniq
  all_groups = (r.groups + r.staff_registrations_groups.map(&:group) + (r.staff_teams_groups.map(&:group) - replacements)).flatten.uniq
  all_groups.sort_by!(&:start)
  conflicts = []
  all_groups.each do |g|
    if last
      conflicts << [last.name, g.name] if g.start < last.end
    end
    last = g
  end
  if conflicts.any?
    puts "#{r.name} (#{r.id}) #{conflicts.map { |c| "[#{c.first}, #{c.last}]" }.join(",")}"
  end
end
