# ���� �迭 ��� Ŭ����
# Jungtaek Lim(Heart)

# ���� �迭 ��� Ŭ����
# @email : ���� �ּ� // String
# @name : �̸� // String
# @homepage : Ȩ������ URL // String
# @ip : ��� ���� IP // String
# @content : ��� ���� // String
# @password : ��� �н����� // String
# @secret : ��� ��� ���� // true/false
# @write_date : ��� �ۼ� �ð� // String
#
# * �ð��� 00:00:00 UTC on January 1, 1970 �������� ���� �ð� - sec
class TTComment
  attr_accessor :email, :name, :homepage, :ip, :content, :password,
    :secret, :write_date
  
  def initialize
    @email = nil
    @name = nil
    @homepage = nil
    @ip = nil
    @content = nil
    @password = nil
    @secret = nil
    @write_date = nil
    
  end

end
