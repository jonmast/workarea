module Workarea
  class Segment
    class ReturningVisitor < Segment
      include LifeCycle
      self.default_rules = [Rules::Sessions.new(minimum: 2)]
    end
  end
end
