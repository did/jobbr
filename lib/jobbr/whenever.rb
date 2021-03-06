require 'jobbr/ohm'

module Jobbr

  module Whenever

    extend self

    # Generates crontab for each scheduled Job using Whenever DSL.
    def schedule_jobs(job_list)
      Jobbr::Ohm.models(Jobbr::Scheduled).each do |job|
        if job.every
          job_list.every job.every[0], job.every[1] do
            job_list.jobbr job.task_name
          end
        end
      end
    end

  end

end
