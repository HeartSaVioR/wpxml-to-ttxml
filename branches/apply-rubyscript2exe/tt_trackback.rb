# ���� �迭 Ʈ���� Ŭ����
# Jungtaek Lim(Heart)

# ���� �迭 Ʈ���� Ŭ����
# @url : Ʈ���� �ּ� // String
# @sitename : Ʈ���� ���� ����Ʈ�� �̸� // String
# @title : Ʈ���� ���� // String
# @excerpt : ������� // String
# @ip : Ʈ���� ���� IP // String
# @receive_date : Ʈ���� ���� ��¥ // String
#
# * �ð��� 00:00:00 UTC on January 1, 1970 �������� ���� �ð� - sec
class TTTrackback
  attr_accessor :url, :sitename, :title, :excerpt, :ip, :receive_date

  def initialize
    @url = nil
    @sitename = nil
    @title = nil
    @excerpt = nil
    @ip = nil
    @receive_date = nil
    
  end
end
