module Workarea
  class SynchronizeUserMetrics
    include Sidekiq::Worker
    include Sidekiq::CallbacksWorker

    sidekiq_options(
      enqueue_on: { User => :save, only_if: -> { tags_changed? } },
      queue: 'low'
    )

    def perform(id)
      user = User.find(id)
      metrics = Metrics::User.find_or_create_by(id: user.email)
      metrics.set(tags: user.tags)
    end
  end
end