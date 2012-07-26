require 'fileutils'


class Record
  def self.length
    return 0
  end

  def set_data(*args)
    @a = args
  end

  def get_data
    @a
  end

  def data_to_raw
    return ""
  end

  def raw_to_data(raw)
    return ""
  end
end

#------
class PointRecord < Record
  def initialize(r=nil, i=nil, iter=nil)
    @a = [0,0,0]

    if r and i and iter then
      set_data(r, i, iter)
    end
  end

  def self.length
    return 24 
  end

  # ID of the record (verification measure)
  # real component of Z
  # imaginary componet of Z
  # iterations
  def set_data(r, i, iter)
    @a = [r, i, iter]
  end

  def set_iter(iter)
    @a[2] = iter
  end

  def get_real
    @a[0]
  end

  def get_imag
    @a[1]
  end

  def get_iter
    @a[2]
  end

  def get_coords
    return get_real, get_iter
  end

  def data_to_raw
    @a.pack("DDQ")
  end

  def raw_to_data(raw)
    @a = raw.unpack("DDQ")
  end
end



class RecordStore
  def initialize(cls, filename, do_not_resume_if_file_exists=false)
    FileUtils.touch(filename) if not File.exists?(filename)
    @f = File.open(filename, 'r+b')
    @f.flock(File::LOCK_EX)
    @cls = cls
    @rlen = eval("#{cls}::length")

    #puts "Opened db #{filename} for records of size #{@rlen}"
  end

  def write_all(r_list)
    puts "WRITE ALL"
    @f.seek(0)
    r_list.each{|r|
      @f.write(r.data_to_raw)
    }
  end

  def write(r)
    @f.seek(0, IO::SEEK_END)
    @f.write(r.data_to_raw)
  end

  def write_at(r, index)
    @f.seek(index*@rlen)
    @f.write(r.data_to_raw)
  end

  def read_at(index)
    @f.seek(index*@rlen)
    data = @f.read(@rlen)
    r = eval("#{@cls}.new")
    r.raw_to_data(data)
    return r
  end

  def read_all
    puts "READ ALL"
    r_list = []
    @f.seek(0)
    while(data = @f.read(@rlen)) do
      r = eval("#{@cls}.new")
      r.raw_to_data(data)
      r_list << r
    end
    return r_list
  end

  def flush
    @f.flush
  end

  def close
    @f.flush
    @f.close
  end

end


#x = RecordStore.new("PointRecord", "sample.db")

#rs = []
#rs << PointRecord.new(0,0,100)
#rs << PointRecord.new(1,1,101)
#rs << PointRecord.new(2,2,101)
#puts "RS"
#rs.each{|r| puts r.get_data.to_s + "\n"}


#x.write_all(rs)

#rs2 = x.read_all
#puts "RS2"
#rs2.each{|r| puts r.get_data.to_s + "\n"}

#x.close
