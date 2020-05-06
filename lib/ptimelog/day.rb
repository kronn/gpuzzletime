# frozen_string_literal: true

module Ptimelog
  # Wrap loading of all entries of a day
  class Day
    def initialize(date)
      @date = NamedDate.new.date(date)
    end

    def entries
      timelog.each_with_object({}) do |(date, lines), entries|
        next unless date                           # guard against the machine
        next unless @date == :all || @date == date # limit to one day if passed

        entries[date] = entries_of_day(lines).each_cons(2).flat_map { |pair| maybe_join(*pair) }

        entries
      end
    end

    private

    def timelog
      Timelog.load
    end

    def entries_of_day(lines)
      entries = []
      start = nil # at the start of the day, we have no previous end

      lines.each do |line|
        entry = Entry.from_timelog(line)
        entry.start_time = start

        entries << entry if entry.valid?

        start = entry.finish_time # store previous ending for nice display of next entry
      end

      entries
    end

    def maybe_join(one, two)
      if one.ticket == two.ticket && one.description == two.description
        joined = one.dup
        joined.finish_time = two.finish_time

        [joined]
      else
        [one, two]
      end
    end
  end
end
