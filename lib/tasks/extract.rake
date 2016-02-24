namespace :extract do
  desc "Extract a list of Utah Counties."
  task :counties => :environment do
    CountyExtractionProcess.perform
  end

  desc "Extract a list of Utah Courts."
  task :courts => :environment do
    CourtExtractionProcess.perform
  end

  #desc "Extract a list of upcoming court hearings."
  #task :court_calendars => :courts do
  #  CourtCalendarExtractionProcess.perform
  #end
end
