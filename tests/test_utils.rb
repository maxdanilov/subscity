def get_file_as_string(filename)
  data = ''
  f = File.open(filename, 'r')
  f.each_line do |line|
    data += line
  end
  data
end

def get_fixture(filename)
  get_file_as_string("tests/fixtures/#{filename}")
end
