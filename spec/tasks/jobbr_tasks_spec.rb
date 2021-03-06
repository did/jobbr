require 'spec_helper'
require 'rake'

describe 'jobbr_tasks' do

  before do
    Rake.application.rake_require 'tasks/jobbr_tasks'
    Rake::Task.define_task(:environment)
  end

  describe 'dynamic jobbr tasks declaration' do

    xit 'should define jobbr tasks' do
      task_names = Rake.application.tasks.map(&:name)
      task_names.should include('jobbr:dummy_heroku_job')
      task_names.should include('jobbr:dummy_scheduled_job')
      task_names.should include('jobbr:logging_job')
      task_names.should include('jobbr:dummy_heroku_job')
    end

    xit 'actually run jobs' do
      expect {
        Rake.application.invoke_task 'jobbr:logging_job'
      }.to change { Jobbr::Run.all.count }.from(0).to(1)

      Jobbr::Run.all.first.status.should be :success
    end

  end

  describe 'job sweeping' do

    before do
      3.times { Jobbr::Run.create(status: :running, started_at: Time.now) }
      2.times { Jobbr::Run.create(status: :success, started_at: Time.now) }
    end

    it 'marks running jobs as failed' do
      expect {
        Rake.application.invoke_task 'jobbr:sweep_running_jobs'
      }.to change { Jobbr::Run.find(status: :failed).count }.from(0).to(3)
    end

  end

end
