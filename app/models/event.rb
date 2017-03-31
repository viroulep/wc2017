# frozen_string_literal: true
class Event
  attr_accessor(:id, :name, :rank)

  def initialize(attributes={})
    @id = attributes[:id]
    @name = attributes[:name]
    @rank = attributes[:rank]
  end

  def self.find(id)
    ALL_EVENTS_BY_ID[id] or raise "Unrecognized event id"
  end

  ALL_EVENTS = [
    {
      id: "333",
      name: "Rubik's Cube",
      rank: 10,
    },
    {
      id: "444",
      name: "4x4 Cube",
      rank: 20,
    },
    {
      id: "555",
      name: "5x5 Cube",
      rank: 30,
    },
    {
      id: "222",
      name: "2x2 Cube",
      rank: 40,
    },
    {
      id: "333bf",
      name: "Rubik's Cube: Blindfolded",
      rank: 50,
    },
    {
      id: "333oh",
      name: "Rubik's Cube: One-handed",
      rank: 60,
    },
    {
      id: "333fm",
      name: "Rubik's Cube: Fewest moves",
      rank: 70,
    },
    {
      id: "333ft",
      name: "Rubik's Cube: With feet",
      rank: 80,
    },
    {
      id: "minx",
      name: "Megaminx",
      rank: 110,
    },
    {
      id: "pyram",
      name: "Pyraminx",
      rank: 120,
    },
    {
      id: "sq1",
      name: "Square-1",
      rank: 130,
    },
    {
      id: "clock",
      name: "Rubik's Clock",
      rank: 140,
    },
    {
      id: "skewb",
      name: "Skewb",
      rank: 150,
    },
    {
      id: "666",
      name: "6x6 Cube",
      rank: 200,
    },
    {
      id: "777",
      name: "7x7 Cube",
      rank: 210,
    },
    {
      id: "444bf",
      name: "4x4 Cube: Blindfolded",
      rank: 500,
    },
    {
      id: "555bf",
      name: "5x5 Cube: Blindfolded",
      rank: 510,
    },
    {
      id: "333mbf",
      name: "Rubik's Cube: Multiple Blindfolded",
      rank: 520,
    },

    {
      id: "magic",
      name: "Rubik's Magic",
      rank: 997,
    },
    {
      id: "mmagic",
      name: "Master Magic",
      rank: 998,
    },
    {
      id: "333mbo",
      name: "Rubik's Cube: Multi blind old style",
      rank: 999,
    },
  ].map { |e| Event.new(e) }

  ALL_EVENTS_BY_ID = Hash[ALL_EVENTS.map { |e| [e.id, e] }]
end
