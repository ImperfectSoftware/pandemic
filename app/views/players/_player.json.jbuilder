json.(PlayerDecorator.new(pair.first), :role)
json.set! :position, ['one', 'two', 'three', 'four'][pair.last]
json.set! :location, pair.first.location.dashed_name
