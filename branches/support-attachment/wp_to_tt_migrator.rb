# Jungtaek Lim(Heart)

require 'rubygems'
require 'hpricot'

require 'tt_category'
require 'tt_post'
require 'tt_comment'
require 'tt_attachment'

# 워드프레스 정보를 태터계열로 변환하고 변환된 정보를 보관하는 클래스
# @wp_categories : 워드프레스 카테고리 정보 // Array of WPCategory
# @wp_posts : 워드프레스 포스트 정보 // Array of WPPost
# @wp_attachments : 워드프레스 첨부파일 정보 // Array of WPAttachment
# @tt_categories : 변환된 태터계열 카테고리 정보 // Array of TTCategory
# @tt_posts : 변환된 태터계열 포스트 정보 // Array of TTPost
# @tt_category_parent_map : 태터 카테고리 정보(부모 추적을 위함) // Map of {String, TTCategory}
# @wp_attachment_map : URL / 첨부파일객체 맵 // Map of {String, WPAttachment}
class WPtoTTMigrator

  attr_reader :tt_categories, :tt_posts

  # wp_categories : 워드프레스 카테고리 정보 // Array of WPCategory
  # wp_posts : 워드프레스 포스트 정보 // Array of WPPost
  # wp_attachments : 워드프레스 첨부파일 정보 // Array of WPAttachment
  def initialize(wp_categories, wp_posts, wp_attachments)
    @wp_categories = wp_categories
    @wp_posts = wp_posts
    
    @tt_categories = []
    @tt_posts = []

    @tt_category_parent_map = {}
    
    # 첨부파일은 URL / 첨부파일객체 맵을 만든다
    @wp_attachment_map = {}
    wp_attachments.each do |attach|
      @wp_attachment_map[attach.attach_url] = attach
	end
  end

  # 변환을 실행
  def migrate
    migrate_categories
    migrate_posts
    
  end

private

  # 카테고리 변환을 실행
  def migrate_categories
    parent_category_map = {}
    children_category_map = {}

    @wp_categories.each do |wp_cat|
      if wp_cat.parent != nil

        if children_category_map[wp_cat.parent] != nil
          # 오류 : 카테고리 깊이는 2로 제한됨(태터계열 제한)
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

 # 포스트 변환을 실행
  def migrate_posts
    @wp_posts.each do |wp_post|

      if wp_post.categories.length != 1
        # 오류 : 포스트의 카테고리는 단 하나여야 함(태터계열 제한)
        puts "Post's category count is 2 or upper!! Can't migrate to TTXML!!"
        puts wp_post.title
        wp_post.categories.each do |category|
          puts category
        end
        exit(-1)
      end

      tt_post = TTPost.new
      tt_post.id = wp_post.post_id
      
      # 공개 / 보호글 / 비공개글 구분
      if "draft" == wp_post.status
      	# 주의 : 임시 상태인 글은 받아들이지 않음
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
      	# 첨부파일 넣자
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
	    		puts "오류) 첨부파일이 실제로 존재하지 않음 : #{attach.attach_url}"
	    		puts "첨부파일을 넣지 않고 계속 진행합니다"
	    		
	    		next
	  		end
      	
      	# 주의 : 모든 타입의 mime 을 알아둘 수는 없기 때문에 
				# attachment 태그의 mime 속성을 빼고 저장할 것임
				
				tt_post.add_attachment(tt_attach)
    	end

      @tt_posts.push(tt_post)

    end

  end
  
  # 워드프레스 글 내용을 태터 계열의 치환자 형식으로 변환한다
  # 첨부파일과 관련된 부분만 치환자 형식으로 변환되고 나머지는 그대로 남는다
  # wp_content : 워드프레스 글 내용 // String
	# post_attach_list : 현 포스트에 첨부된 첨부파일 리스트 // Array of WPAttachment
  def convert_content(wp_content, post_attach_list)
		doc = Hpricot(wp_content)
		
		# img 태그에서 a 태그 관련해서 처리하는 것이 있기 때문에 
		# img 태그 작업을 먼저 수행하여야 한다
		
		doc.search("//img|IMG") do |img|
		  convert_content_img_tag(img, post_attach_list)
		end
		
		doc.search("//a|A") do |a|
		  convert_content_a_tag(a, post_attach_list)
	  end
  	
  	return doc.to_s
  end
  
	# IMG 태그가 첨부파일과 연결된 태그인지 확인하고 맞으면 치환자로 변환한다
	# 치환자로 변환할 때 해당 첨부파일은 첨부파일 리스트에 추가한다
	# img_tag_elem : IMG 태그를 가리키는 Element 객체 // Hpricot::Elem
	# post_attach_list : 현 포스트에 첨부된 첨부파일 리스트 // Array of WPAttachment
  def convert_content_img_tag(img_tag_elem, post_attach_list)
		src_url = img_tag_elem.get_attribute('src')
	  src_url = img_tag_elem.get_attribute('SRC') if nil == src_url
	  
	  wp_attach = @wp_attachment_map[src_url]
	  
	  return if nil == wp_attach
	  
	  width = img_tag_elem.get_attribute('width')
	  width = img_tag_elem.get_attribute('WIDTH') if nil == width	  
	  # 태그 정보가 없으면 실제 이미지 파일 크기 구해서 넣기
	  width = wp_attach.width if nil == width
	
	  height = img_tag_elem.get_attribute('height')
	  height = img_tag_elem.get_attribute('HEIGHT') if nil == height
	  # 태그 정보가 없으면 실제 이미지 파일 크기 구해서 넣기
	  height = wp_attach.height if nil == height
	  
	  if nil == height || nil == width || 0 == height || 0 == width
	  	# 첨부파일이 그림 확장자가 아니지만 실제로는 그림인 경우
	  	# 다시 얻어서 넣어 주자
	  	begin
	  		width, height = get_image_size_from_content( get_url_content(src_url) )
	  		
	  		wp_attachment.width = width
	  		wp_attachment.height = height
			rescue OpenURI::HTTPError => httperr
				# 일단은 아무것도 하지 않는다... 나중에 에러처리할 것임
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
	
	  # 파일명으로 바꾸기
	  replacer += "#{wp_attach.name}|"
	
	  replacer += "width=#{width} height=#{height} alt=\"\"|_##]"
	
	  # A 태그로 둘러싼 IMG 태그의 경우 A 태그를 찾는다
	  # 치환자 변환 중 상위인 A 태그 작업에 의해 날아가기 때문
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

	# A 태그가 첨부파일과 연결된 태그인지 확인하고 맞으면 치환자로 변환한다
	# 치환자로 변환할 때 해당 첨부파일은 첨부파일 리스트에 추가한다
	# a_tag_elem : A 태그를 가리키는 Element 객체 // Hpricot::Elem
	# post_attach_list : 현 포스트에 첨부된 첨부파일 리스트 // Array of WPAttachment
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
