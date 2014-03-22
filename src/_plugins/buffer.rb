require 'buff'

class Buffer < Jekyll::Generator
  def generate(site)
    if site.config['send_to_buffer']
      post = most_recent_post(site)

      post_date = post.date.strftime('%Y-%m-%d')
      today_date = Date.today.strftime('%Y-%m-%d')
      puts "#{post_date} #{today_date}"
      if post_date == today_date
        message = generate_message(post)
        log "Buffer message: \"#{message}\""
        buffer(message, site)
      else
        log 'Not sending latest promotion because older than today...'
      end
    else
      log 'Not sending latest post promotion to Buffer...'
    end
  end

  private

  def log(message)
    puts "\n\n#{message}\n\n"
  end

  def generate_message(post)
    promotion_message = post.data['promotion'] || ''
    "#{promotion_message} #{post.location_on_server}"
  end

  def most_recent_post(site)
    site.posts.reduce do |memo, post|
      memo.date > post.date ? memo : post
    end
  end

  def buffer(message, site)
    access_token = ENV['BUFFER_ACCESS_TOKEN'] || site.config['buffer_access_token']
    fail ArgumentError, 'No Buffer access token!' unless access_token
    client = Buff::Client.new(access_token)
    content = { body: { text: message, top: true, shorten: true,
                        profile_ids: site.config['buffer_profiles'] } }
    # response = client.create_update(content)
    puts client
    response = content
    log("Buffer API Response: #{response.inspect}")
  end
end
