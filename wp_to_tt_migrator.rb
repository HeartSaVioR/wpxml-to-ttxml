# Jungtaek Lim(Heart)

require 'rubygems'
require 'hpricot'

require 'tt_category'
require 'tt_post'
require 'tt_comment'
require 'tt_attachment'

# ���������� ������ ���Ͱ迭�� ��ȯ�ϰ� ��ȯ�� ������ �����ϴ� Ŭ����
# @wp_categories : ���������� ī�װ� ���� // Array of WPCategory
# @wp_posts : ���������� ����Ʈ ���� // Array of WPPost
# @wp_attachments : ���������� ÷������ ���� // Array of WPAttachment
# @tt_categories : ��ȯ�� ���Ͱ迭 ī�װ� ���� // Array of TTCategory
# @tt_posts : ��ȯ�� ���Ͱ迭 ����Ʈ ���� // Array of TTPost
# @tt_category_parent_map : ���� ī�װ� ����(�θ� ������ ����) // Map of {String, TTCategory}
# @wp_attachment_map : URL / ÷�����ϰ�ü �� // Map of {String, WPAttachment}
class WPtoTTMigrator

  attr_reader :tt_categories, :tt_posts

  # wp_categories : ���������� ī�װ� ���� // Array of WPCategory
  # wp_posts : ���������� ����Ʈ ���� // Array of WPPost
  # wp_attachments : ���������� ÷������ ���� // Array of WPAttachment
  def initialize(wp_categories, wp_posts, wp_attachments)
    @wp_categories = wp_categories
    @wp_posts = wp_posts
    
    @tt_categories = []
    @tt_posts = []

    @tt_category_parent_map = {}
    
    # ÷�������� URL / ÷�����ϰ�ü ���� �����
    @wp_attachment_map = {}
    wp_attachments.each do |attach|
      @wp_attachment_map[attach.attach_url] = attach
	end
  end

  # ��ȯ�� ����
  def migrate
    migrate_categories
    migrate_posts
    
  end

private

  # ī�װ� ��ȯ�� ����
  def migrate_categories
    parent_category_map = {}
    children_category_map = {}

    @wp_categories.each do |wp_cat|
      if wp_cat.parent != nil

        if children_category_map[wp_cat.parent] != nil
          # ���� : ī�װ� ���̴� 2�� ���ѵ�(���Ͱ迭 ����)
          puts "Category depth is 3 or upper!! Can't migrate to TTXML!!"
          exit(-1)
        end

        tt_category = parent_category_map[wp_cat.parent]

        if tt_category != nil
          tt_category.add_child(wp_cat.name)
        else
          tt_category = TTCategory.new
          tt_category.name = wp_cat.parent
          tt_category.add_child(wp_cat.name)

          parent_category_map[wp_cat.parent] = tt_category
        end
        
        children_category_map[wp_cat.name] = wp_cat
      else
        tt_category = parent_category_map[wp_cat.name]

        if tt_category == nil
          tt_category = TTCategory.new
          tt_category.name = wp_cat.name
          
          parent_category_map[wp_cat.name] = tt_category
        end
      end
    end

    parent_category_map.each_value do |category|
      @tt_categories.push(category)

      category.children.each do |child_category|
        @tt_category_parent_map[child_category] = category
      end

    end

  end

 # ����Ʈ ��ȯ�� ����
  def migrate_posts
    @wp_posts.each do |wp_post|

      if wp_post.categories.length != 1
        # ���� : ����Ʈ�� ī�װ��� �� �ϳ����� ��(���Ͱ迭 ����)
        puts "Post's category count is 2 or upper!! Can't migrate to TTXML!!"
        puts wp_post.title
        wp_post.categories.each do |category|
          puts category
        end
        exit(-1)
      end

      tt_post = TTPost.new
      tt_post.id = wp_post.post_id
      
      # ���� / ��ȣ�� / ������� ����
      if "draft" == wp_post.status
      	# ���� : �ӽ� ������ ���� �޾Ƶ����� ����
      	puts "\"#{wp_post.title}\" : (Warning)Draft post is not supported"
      	
      	next
  	  elsif "private" == wp_post.status
  	  	tt_post.visibility = "private"
  	  	tt_post.password = nil
  	  else # if "publish" == wp_post.status
	  	if nil != wp_post.password
  	  	  tt_post.visibility = "protected"
  	  	  tt_post.password = wp_post.password
  	  	else
	  	  tt_post.visibility = "public"
  		  tt_post.password = nil
  	  	end
  	  end
            
      tt_post.title = wp_post.title
      tt_post.location = "/"
      
      tt_post.accept_comment = wp_post.comment_status
      tt_post.accept_trackback = wp_post.ping_status

      pub_date = Time.parse(wp_post.pub_date)
      post_date = Time.parse(wp_post.post_date)

      tt_post.publish_date = pub_date.to_i
      tt_post.create_date = post_date.to_i
      tt_post.modify_date = pub_date.to_i
      
      post_attach_list = []
      tt_post.content = convert_content(wp_post.content, post_attach_list)
      
      post_category = nil

      wp_post.categories.each do |key, value|
        # must have one!!!
        post_category = key
        
        break
      end

      parent_category = @tt_category_parent_map[post_category]
      
      if parent_category != nil
        tt_post.category = parent_category.name + "/" + post_category
      else
        tt_post.category = post_category
      end

      wp_post.tags.each_value do |tag|
        tt_post.add_tag(tag)
      end

      wp_post.comments.each do |comment|
        tt_comment = TTComment.new

        tt_comment.name = comment.author
        tt_comment.ip = comment.ip
        tt_comment.homepage = comment.url
        tt_comment.password = nil
        tt_comment.secret = false
        tt_comment.content = comment.content

        tt_comment.write_date = Time.parse(comment.write_date).to_i
        
        tt_post.add_comment(tt_comment)
      end
      
      post_attach_list.each do |attach|
      	# ÷������ ����
      	tt_attach = TTAttachment.new
      	
      	tt_attach.name = attach.name
      	tt_attach.label = attach.name
      	tt_attach.attached = Time.parse(attach.post_date).to_i
      	
      	tt_attach.width = attach.width
      	tt_attach.height = attach.height
      	
      	begin
      		attach_content = get_url_content(attach.attach_url)
      		
      		tt_attach.attach_size = attach_content.length
      		tt_attach.content = content_to_base64_str( attach_content )
      		
	    	rescue OpenURI::HTTPError => httperr
	    		puts "����) ÷�������� ������ �������� ���� : #{attach.attach_url}"
	    		puts "÷�������� ���� �ʰ� ��� �����մϴ�"
	    		
	    		next
	  		end
      	
      	# ���� : ��� Ÿ���� mime �� �˾Ƶ� ���� ���� ������ 
				# attachment �±��� mime �Ӽ��� ���� ������ ����
				
				tt_post.add_attachment(tt_attach)
    	end

      @tt_posts.push(tt_post)

    end

  end
  
  # ���������� �� ������ ���� �迭�� ġȯ�� �������� ��ȯ�Ѵ�
  # ÷�����ϰ� ���õ� �κи� ġȯ�� �������� ��ȯ�ǰ� �������� �״�� ���´�
  # wp_content : ���������� �� ���� // String
	# post_attach_list : �� ����Ʈ�� ÷�ε� ÷������ ����Ʈ // Array of WPAttachment
  def convert_content(wp_content, post_attach_list)
		doc = Hpricot(wp_content)
		
		# img �±׿��� a �±� �����ؼ� ó���ϴ� ���� �ֱ� ������ 
		# img �±� �۾��� ���� �����Ͽ��� �Ѵ�
		
		doc.search("//img|IMG") do |img|
		  convert_content_img_tag(img, post_attach_list)
		end
		
		doc.search("//a|A") do |a|
		  convert_content_a_tag(a, post_attach_list)
	  end
  	
  	return doc.to_s
  end
  
	# IMG �±װ� ÷�����ϰ� ����� �±����� Ȯ���ϰ� ������ ġȯ�ڷ� ��ȯ�Ѵ�
	# ġȯ�ڷ� ��ȯ�� �� �ش� ÷�������� ÷������ ����Ʈ�� �߰��Ѵ�
	# img_tag_elem : IMG �±׸� ����Ű�� Element ��ü // Hpricot::Elem
	# post_attach_list : �� ����Ʈ�� ÷�ε� ÷������ ����Ʈ // Array of WPAttachment
  def convert_content_img_tag(img_tag_elem, post_attach_list)
		src_url = img_tag_elem.get_attribute('src')
	  src_url = img_tag_elem.get_attribute('SRC') if nil == src_url
	  
	  wp_attach = @wp_attachment_map[src_url]
	  
	  return if nil == wp_attach
	  
	  width = img_tag_elem.get_attribute('width')
	  width = img_tag_elem.get_attribute('WIDTH') if nil == width	  
	  # �±� ������ ������ ���� �̹��� ���� ũ�� ���ؼ� �ֱ�
	  width = wp_attach.width if nil == width
	
	  height = img_tag_elem.get_attribute('height')
	  height = img_tag_elem.get_attribute('HEIGHT') if nil == height
	  # �±� ������ ������ ���� �̹��� ���� ũ�� ���ؼ� �ֱ�
	  height = wp_attach.height if nil == height
	  
	  if nil == height || nil == width || 0 == height || 0 == width
	  	# ÷�������� �׸� Ȯ���ڰ� �ƴ����� �����δ� �׸��� ���
	  	# �ٽ� �� �־� ����
	  	begin
	  		width, height = get_image_size_from_content( get_url_content(src_url) )
	  		
	  		wp_attachment.width = width
	  		wp_attachment.height = height
			rescue OpenURI::HTTPError => httperr
				# �ϴ��� �ƹ��͵� ���� �ʴ´�... ���߿� ����ó���� ����
			end
	  	
  	end
	
	  align = img_tag_elem.get_attribute('align')
	  align = img_tag_elem.get_attribute('ALIGN') if nil == align
	
	  replacer = "[##_1"
	  case align
	  when 'center'
	  when 'CENTER'
	    replacer += 'C'
	  when 'left'
	  when 'LEFT'
	    replacer += 'L'
	  when 'right'
	  when 'RIGHT'
	    replacer += 'R'
	  else
	    replacer += 'L'
	  end
	
	  replacer += '|'
	
	  # ���ϸ����� �ٲٱ�
	  replacer += "#{wp_attach.name}|"
	
	  replacer += "width=#{width} height=#{height} alt=\"\"|_##]"
	
	  # A �±׷� �ѷ��� IMG �±��� ��� A �±׸� ã�´�
	  # ġȯ�� ��ȯ �� ������ A �±� �۾��� ���� ���ư��� ����
	  parent_elem = img_tag_elem.parent
	  a_tag_elem = nil
	  
	  while nil != parent_elem
	  	if "A" == parent_elem.name.upcase
	  		a_tag_elem = parent_elem
	  		break
  		end
	  	
  	end
  	
  	if nil != a_tag_elem
	  	a_tag_elem.swap(replacer)
  	else
	  	img_tag_elem.swap(replacer)
  	end
	  
	  post_attach_list.push wp_attach
  end

	# A �±װ� ÷�����ϰ� ����� �±����� Ȯ���ϰ� ������ ġȯ�ڷ� ��ȯ�Ѵ�
	# ġȯ�ڷ� ��ȯ�� �� �ش� ÷�������� ÷������ ����Ʈ�� �߰��Ѵ�
	# a_tag_elem : A �±׸� ����Ű�� Element ��ü // Hpricot::Elem
	# post_attach_list : �� ����Ʈ�� ÷�ε� ÷������ ����Ʈ // Array of WPAttachment
  def convert_content_a_tag(a_tag_elem, post_attach_list)
  	href_url = a_tag_elem.get_attribute('href')
  	href_url = a_tag_elem.get_attribute('HREF') if nil == href_url
  	  	
  	wp_attach = @wp_attachment_map[href_url]
	  return if nil == wp_attach
	  
	  replacer = "[##_1L|#{wp_attach.name}||_##]"
	  
	  a_tag_elem.swap(replacer)
	  
	  post_attach_list.push wp_attach
  	
  end
  
end
