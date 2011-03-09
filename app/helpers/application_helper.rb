module ApplicationHelper
  class YirUser
    attr_accessor :first_name, :last_name, :pic_id, :profile_url, :month

    def initialize(first_name, last_name, pic_id, profile_url, month)
      @first_name = first_name
      @last_name = last_name
      @pic_id = pic_id
      @profile_url = profile_url
      @month = month
    end

    def fullname
      if @last_name == nil or @last_name == "" then
        @first_name
      else
        @first_name + " " + @last_name
      end
    end

    def short_name
      @first_name.split[0]
    end

    def hash
      @pic_id.hash
    end

    def eql?(other)
      @pic_id.eql? other.pic_id
    end

    def to_s
      "fname:#{@first_name}\tlname:#{@last_name}\tpic:#{@pic_id}\turl:#{@profile_url}\tmonth:#{@month}"
    end
  end
end
