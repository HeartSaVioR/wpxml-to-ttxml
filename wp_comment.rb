# Jungtaek Lim(Heart)

# ���������� ����� ǥ���ϴ� Ŭ����
# id : ���� ��ȣ // String
# author : ��� �ۼ��� // String
# email : ���� �ּ� // String
# url : �ۼ��ڰ� ���� URL // String
# ip : �ۼ��� ���� IP // String
# write_date : �ۼ� ��¥ // String
# content : ���� // String
#
# �ð��� Ÿ�� : String(YYYY-MM-DD 24HR:MI:SS)
class WPComment
  attr_accessor :id, :author, :email, :url, :ip, :write_date, :content

  def initialize
    @id = nil
    @author = nil
    @email = nil
    @url = nil
    @ip = nil
    
    @write_date = nil
    @content = nil

  end
  
end
