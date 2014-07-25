
def staging
  "build/staging"
end

sources = (Rake::FileList["{bin,lib,spec,locales}/{**/*}"] + Rake::FileList["{bin,lib,spec,locales,LICENSE}"])

# Create directory and file targets for everything we
# might want to copy
sources.each do |source|
  target = File.join(staging, source) 
  target_dir = File.dirname(target)
  stat = File.lstat(source)

  if stat.file?
    file target => [source, target_dir] do
      cp source, target
    end unless Rake::Task.task_defined?(target)
  elsif stat.directory?
    directory target => [target_dir] do
      mkdir target
    end unless Rake::Task.task_defined?(target)
  end
end

namespace "build" do
  task "copy" => sources.collect { |s| File.join(staging, s) }
  task "all" => "copy"
end

namespace "clean" do
  task "copy" do
    sources.collect { |f| File.join(staging, f) }.select { |f| File.file?(f) }.each { |f| rm f }

    # FileUtils#rm doesn't support directories... use Dir.delete instead.
    sources.collect { |f| File.join(staging, f) }.select { |f| File.directory?(f) }.sort_by { |f| -f.bytesize }.each { |f| Dir.delete(f) }
  end

  task "all" => "copy"
end
