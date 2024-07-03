require 'rubygems'
require 'gosu'
require 'fastimage'

TOP_COLOR= Gosu::Color.new(0xFF1EB1FA)
BOTTOM_COLOR= Gosu::Color.new(0xFF1D4DB5)
WORD_POS= 500

SONG_LIST_POS_X= 500
SONG_LIST_POS_Y= 70

MENU_INTERFACE1_X= 50
MENU_INTERFACE2_X= 170
MENU_INTERFACE_Y= 500
MENU_WIDTH= 100
MENU_HEIGHT= 50

FEATURE_INTERFACE1_X= 10
FEATURE_INTERFACE2_X= 180
FEATURE_INTERFACE_Y= 10
FEATURE_WIDTH= 150
FEATURE_HEIGHT= 40

SPACING=25

module ZOrder
	BACKGROUND, PLAYER, UI = *0..2
end
  
module Page
	HOME, LIBRARY = *0..1
end

module Library
	ALLSONG, PLAYLIST = *0..1
end

class ArtWork
	attr_accessor :bmp, :dim
	def initialize(file, leftX, topY)
		@bmp= Gosu::Image.new(file)
		@dim= Dimension.new(leftX, topY, leftX + @bmp.width(), topY + @bmp.height())
	end
end

class Album
	attr_accessor :title, :artist, :artwork, :tracks
	def initialize (title, artist, artwork, tracks)
		@title= title
		@artist= artist
		@artwork= artwork
		@tracks= tracks
	end
end
  
class Track
	attr_accessor :name, :location, :dim
	def initialize(name, location, dim)
		@name= name
		@location= location
		@dim= dim
	end
end
  
class Dimension
	attr_accessor :leftX, :topY, :rightX, :bottomY
	def initialize(leftX, topY, rightX, bottomY)
		@leftX= leftX
		@topY= topY
		@rightX= rightX
		@bottomY= bottomY
	end
end

class MusicPlayerMain < Gosu::Window

	def initialize
	    super 800, 600
	    self.caption ="Music Player"

		# Reads in an array of albums from a file and then prints all the albums in the
		# array to the terminal
	    @track_font= Gosu::Font.new(25)
	    @albums= read_albums()
	    @album_current_playing= -1
	    @track_current_playing= -1
		@page= Page::HOME

		@page_font= Gosu::Font.new(20)
		@songs= song_position()
		@library_page= Library::ALLSONG
		@song_choosed= -1
		@liked_song=Array.new()
		@liked_songs_data=Array.new()
		@liked_track_current_playing= -1

		@previous_song_button=Gosu::Image.new("images/previous_song.png")
		@next_song_button=Gosu::Image.new("images/next_song.png")
		@pause_button=Gosu::Image.new("images/continue_button.png")


		@previous_button_data=music_button("images/previous_song.png", WORD_POS, 500)
		@next_button_data=music_button("images/next_song.png", WORD_POS+200, 500)
		@pause_button_data=music_button("images/continue_button.png", WORD_POS+100, 500)

		@previous=-1
		@next=-1
		@pause=-1

		@user_pause=-1

		@added_to_playlist=Array.new()
	end

	# Put in your code here to load albums and tracks
	def read_albums()
		music_file= File.new("music.txt", "r")
		count= music_file.gets().chomp.to_i
		albums= Array.new()
		i=0
		while i<count
			album= read_album(music_file, i)
			albums<< album
			i+=1
		end
		music_file.close()
		return albums
	end

	def read_album(music_file, i)
		title= music_file.gets().chomp
		artist= music_file.gets().chomp

		#Locate the artworks position
		image_path= music_file.gets().chomp
		size_array= FastImage.size(image_path) #get the image length and width from the file
		width= size_array[0].to_i
		height= size_array[1].to_i

		if i%2==0
			leftX=15
		else
			leftX=15+width+20
		end
		topY=height*(i/2)+30+20*(i/2)
		artwork= ArtWork.new(image_path, leftX, topY)
		#-----------------------------------------------------#

		tracks= read_tracks(music_file)
		album= Album.new(title, artist, artwork, tracks)
		return album
	end

	def read_tracks(music_file)
		count= music_file.gets().chomp.to_i
		tracks= Array.new()
		i=0
		while i<count
			track= read_track(music_file, i)
			tracks<< track
			i+=1
		end
		return tracks
	end

	def read_track(music_file, i)
		name= music_file.gets().chomp
		location= music_file.gets().chomp
		text_font=25
		leftX= WORD_POS
		topY= 40*i+30
		rightX = leftX + @track_font.text_width(name)
		bottomY = topY + text_font #track font size(height)
		dim = Dimension.new(leftX, topY, rightX, bottomY)

		track= Track.new(name, location, dim)
		return track
	end

	def song_position()
		i=0
		#puts @albums[i].tracks.length()
		album_length=@albums[i].tracks.length().to_i
		#puts @albums.length()
		albums_length=@albums.length().to_i

		songs=Array.new()
		x=SONG_LIST_POS_X
		y=SONG_LIST_POS_Y
		song_count=1
		while(i<albums_length)
			album=@albums[i]
			j=0
			count= album.tracks.length
			while j<count
				track_name= album.tracks[j].name
				track_location= album.tracks[j].location
				song=read_song(song_count, track_name, track_location, x, y)
				songs<<song
				y+=SPACING
				song_count+=1
				j+=1
			end
			i+=1
		end
		return songs
	end

	def read_song(song_count, track_name, track_location, x, y)
		text_font=25
		leftX= x
		topY= y
		rightX = leftX + @track_font.text_width(track_name)
		bottomY = topY + text_font #track font size(height)
		dim = Dimension.new(leftX, topY, rightX, bottomY)

		song=Track.new(track_name, track_location, dim)
		return song
	end

	def song_data(i, x, y)
		song_name=@songs[i].name
		song_location=@songs[i].location

		text_font=25
		leftX= x
		topY= y
		rightX = leftX + @track_font.text_width(song_name)
		bottomY = topY + text_font #track font size(height)
		dim = Dimension.new(leftX, topY, rightX, bottomY)
		
		song_choosed=Track.new(song_name, song_location, dim)
		return song_choosed
	end

	# Draws the artwork on the screen for all the albums

	def draw_albums(albums)
		i= 0
		count= albums.length
		while i<count
			album= albums[i]
			album.artwork.bmp.draw(album.artwork.dim.leftX, album.artwork.dim.topY, z = ZOrder::PLAYER)
			i+=1
		end
	end

	def draw_album(albums, i)
		album= albums[i]
		album.artwork.bmp.draw(album.artwork.dim.leftX, album.artwork.dim.topY, z = ZOrder::PLAYER)
	end
	
	def draw_tracks(album)
		i= 0
		count= album.tracks.length
		while i<count
			track= album.tracks[i]
			display_track(track)
			i+=1
		end
	end



	def draw_current_playing(track_num, album)
		#puts @track_current_playing
		if (track_num>=0 && track_num<album.tracks.length)
			track=album.tracks[track_num]
			text_font=25
			draw_rect(track.dim.leftX-10, track.dim.topY, 5, text_font, Gosu::Color::BLACK, z = ZOrder::PLAYER)
		end
	end

	def draw_current_liked_track_playing(track_num)
		if(track_num>=0 && track_num<@liked_songs_data.length)
			track=@liked_songs_data[track_num]
			text_font=25
			draw_rect(track.dim.leftX-10, track.dim.topY, 5, text_font, Gosu::Color::BLACK, z = ZOrder::PLAYER)
		end
	end


	# Detects if a 'mouse sensitive' area has been clicked on
	# i.e either an album or a track. returns true or false

	def area_clicked(leftX, topY, rightX, bottomY)
		# complete this code
		if (mouse_x > leftX && mouse_x < rightX) && (mouse_y > topY && mouse_y < bottomY)
			return true
		end
		return false
	end

	# Takes a String title and an Integer ypos
	# You may want to use the following:
	def display_track(track)
		@track_font.draw(track.name, WORD_POS, track.dim.topY, ZOrder::PLAYER, 1.0, 1.0, Gosu::Color::BLACK)
	end


	# Takes a track index and an Album and plays the Track from the Album

	def playTrack(album)
		# complete the missing code
		@song = Gosu::Song.new(album)
		@song.play(false)
		# Uncomment the following and indent correctly:
		#	end
		# end
	end

	#user interaction 
	def user_interaction()
		previous_button_coordinate=@previous_button_data
		if area_clicked(previous_button_coordinate.leftX, previous_button_coordinate.topY, previous_button_coordinate.rightX, previous_button_coordinate.bottomY)
			#puts "choosed previous song"
			@previous=1

			return
		end
		next_button_coordinate=@next_button_data
		if area_clicked(next_button_coordinate.leftX, next_button_coordinate.topY, next_button_coordinate.rightX, next_button_coordinate.bottomY)
			#puts "choosed next song"
			@next=1
			
			return
		end
		pause_button_coordinate=@pause_button_data
		if area_clicked(pause_button_coordinate.leftX, pause_button_coordinate.topY, pause_button_coordinate.rightX, pause_button_coordinate.bottomY)
			#puts "pause the song"
			@pause=1

			return
		end
	end

	# Draw a coloured background using TOP_COLOR and BOTTOM_COLOR

	def draw_background
        draw_quad(0, 0, TOP_COLOR, 800, 0, TOP_COLOR, 0, 600, BOTTOM_COLOR, 800, 600, BOTTOM_COLOR, ZOrder::BACKGROUND)
	end

	# Not used? Everything depends on mouse actions.

	def update
		#auto play in an album
		if(@album_current_playing>=0 && @song!=nil && @song.playing? !=true && !@user_pause)
			album_num=@albums[@album_current_playing]
			@track_current_playing= (@track_current_playing+1) % album_num.tracks.length()
			playTrack(album_num.tracks[@track_current_playing].location)
		end

		if(@liked_track_current_playing>=0 && @song!=nil && @song.playing? !=true && !@user_pause)
			@liked_track_current_playing= (@liked_track_current_playing+1) % @liked_song.length
			playTrack(@liked_songs_data[@liked_track_current_playing].location)
		end

		#changing songs and pause
		if(@previous==1 && @song!=nil && @song.playing? ==true )
			if(@page==Page::HOME)
				album_num=@albums[@album_current_playing]
				@track_current_playing= (@track_current_playing-1) % album_num.tracks.length()
				playTrack(album_num.tracks[@track_current_playing].location)
				@previous=-1
				return
			elsif(@page==Page::LIBRARY && @library_page==Library::PLAYLIST)
				@liked_track_current_playing= (@liked_track_current_playing-1) % @liked_song.length
				playTrack(@liked_songs_data[@liked_track_current_playing].location)
				@previous=-1
				return
			end
		end

		if(@next==1 && @song!=nil && @song.playing? ==true )
			if(@page==Page::HOME)
				album_num=@albums[@album_current_playing]
				@track_current_playing= (@track_current_playing+1) % album_num.tracks.length()
				playTrack(album_num.tracks[@track_current_playing].location)
				@next=-1
				return
			elsif(@page==Page::LIBRARY && @library_page==Library::PLAYLIST)
				@liked_track_current_playing= (@liked_track_current_playing+1) % @liked_song.length
				playTrack(@liked_songs_data[@liked_track_current_playing].location)
				@next=-1
				return
			end
		end

		if(@pause==1 && @song!=nil)
			if(@page==Page::HOME)

				if(@song.playing? ==true)
					@song.pause
				else
					@song.play(false)
				end
				@user_pause=1
				@pause=-1

				return
			elsif(@page==Page::LIBRARY && @library_page==Library::PLAYLIST)

				if(@song.playing? ==true)
					@song.pause
				else
					@song.play(false)
				end
				@user_pause=1 
				@pause=-1

				return
			end
		end
	end

 	# Draws the album images and the track list for the selected album


	def home_page_display()
		#pages interface
		Gosu.draw_rect(MENU_INTERFACE1_X, MENU_INTERFACE_Y, MENU_WIDTH, MENU_HEIGHT, Gosu::Color::RED, ZOrder::UI, mode=:default)
		@page_font.draw_text("Home", MENU_INTERFACE1_X+15, MENU_INTERFACE_Y+15, ZOrder::UI, 1.0, 1.0, Gosu::Color::BLACK)
		Gosu.draw_rect(MENU_INTERFACE2_X, MENU_INTERFACE_Y, MENU_WIDTH, MENU_HEIGHT, Gosu::Color::GREEN, ZOrder::UI, mode=:default)
		@page_font.draw_text("Library", MENU_INTERFACE2_X+15, MENU_INTERFACE_Y+15, ZOrder::UI, 1.0, 1.0, Gosu::Color::BLACK)
		draw_albums(@albums)
		if @album_current_playing>=0
			album=@albums[@album_current_playing]
			track_num=@track_current_playing
			draw_tracks(album)
			draw_current_playing(track_num, album)
			




			@previous_song_button.draw(WORD_POS, 500, ZOrder::UI)
			@next_song_button.draw(WORD_POS+200, 500, ZOrder::UI)
			@pause_button.draw(WORD_POS+100, 500, ZOrder::UI)

		end
	end

	def music_button(image_path, leftX, topY)

		size_array= FastImage.size(image_path) #get the image length and width from the file
		width= size_array[0].to_i
		height= size_array[1].to_i



		button= Dimension.new(leftX, topY, leftX + width, topY + height)
		return button
	end

	def library_page_display()
		#pages interface
		Gosu.draw_rect(MENU_INTERFACE1_X, MENU_INTERFACE_Y, MENU_WIDTH, MENU_HEIGHT, Gosu::Color::GREEN, ZOrder::UI, mode=:default)
		@page_font.draw_text("Home", MENU_INTERFACE1_X+15, MENU_INTERFACE_Y+15, ZOrder::UI, 1.0, 1.0, Gosu::Color::BLACK)
		Gosu.draw_rect(MENU_INTERFACE2_X, MENU_INTERFACE_Y, MENU_WIDTH, MENU_HEIGHT, Gosu::Color::RED, ZOrder::UI, mode=:default)
		@page_font.draw_text("Library", MENU_INTERFACE2_X+15, MENU_INTERFACE_Y+15, ZOrder::UI, 1.0, 1.0, Gosu::Color::BLACK)

		if(@library_page==Library::ALLSONG)
			#features interface
			Gosu.draw_rect(FEATURE_INTERFACE1_X, FEATURE_INTERFACE_Y, FEATURE_WIDTH, FEATURE_HEIGHT, Gosu::Color::RED, ZOrder::UI, mode=:default)
			@page_font.draw_text("Your songs", FEATURE_INTERFACE1_X+15, FEATURE_INTERFACE_Y+15, ZOrder::UI, 1.0, 1.0, Gosu::Color::BLACK)
			Gosu.draw_rect(FEATURE_INTERFACE2_X, FEATURE_INTERFACE_Y, FEATURE_WIDTH, FEATURE_HEIGHT, Gosu::Color::GREEN, ZOrder::UI, mode=:default)
			@page_font.draw_text("Your playlist", FEATURE_INTERFACE2_X+15, FEATURE_INTERFACE_Y+15, ZOrder::UI, 1.0, 1.0, Gosu::Color::BLACK)

			
			#songs display
			i=0
			all_songs=@songs.length
			x=SONG_LIST_POS_X
			y=SONG_LIST_POS_Y
			song_count=1
			while(i<all_songs)

				track= @songs[i].name


				j=0
				while(j<@added_to_playlist.length)
					if(i==@added_to_playlist[j])
						draw_rect(x-10, y, 5, 25, Gosu::Color::RED, z = ZOrder::PLAYER)
					end
					j+=1
				end

				@track_font.draw("#{song_count}, #{track}", x, y, ZOrder::PLAYER, 1.0, 1.0, Gosu::Color::BLACK)



				y+=SPACING
				song_count+=1
				i+=1
			end
		elsif(@library_page==Library::PLAYLIST)
			#features interface
			Gosu.draw_rect(FEATURE_INTERFACE1_X, FEATURE_INTERFACE_Y, FEATURE_WIDTH, FEATURE_HEIGHT, Gosu::Color::GREEN, ZOrder::UI, mode=:default)
			@page_font.draw_text("Your songs", FEATURE_INTERFACE1_X+15, FEATURE_INTERFACE_Y+15, ZOrder::UI, 1.0, 1.0, Gosu::Color::BLACK)
			Gosu.draw_rect(FEATURE_INTERFACE2_X, FEATURE_INTERFACE_Y, FEATURE_WIDTH, FEATURE_HEIGHT, Gosu::Color::RED, ZOrder::UI, mode=:default)
			@page_font.draw_text("Your playlist", FEATURE_INTERFACE2_X+15, FEATURE_INTERFACE_Y+15, ZOrder::UI, 1.0, 1.0, Gosu::Color::BLACK)
			
			i=0
			x=SONG_LIST_POS_X
			y=SONG_LIST_POS_Y
			#puts @liked_song.length
			while(i<@liked_song.length)
				track=@liked_song[i]

				@track_font.draw("#{i+1}, #{track}", x, y, ZOrder::PLAYER, 1.0, 1.0, Gosu::Color::BLACK)

				j=0
				while(j<@songs.length)
					if(@songs[j].name==track)
						@liked_songs_data << song_data(j, x, y)
						#puts @liked_songs_data[0].location
						#puts @liked_songs_data[0].dim.topY
						if(@liked_track_current_playing>=0)
							draw_current_liked_track_playing(@liked_track_current_playing)
						end
						break
					end
					j+=1
				end

				#puts track
				y+=SPACING
				i+=1
			end
			@previous_song_button.draw(x, 500, ZOrder::UI)
			@next_song_button.draw(x+200, 500, ZOrder::UI)
			@pause_button.draw(x+100, 500, ZOrder::UI)


		end
	end

	def draw
		# Complete the missing code
		
		draw_background()
		

		if(@page==Page::HOME)
			home_page_display()
		elsif(@page==Page::LIBRARY)
			library_page_display()
		end
		

	end

 	def needs_cursor?; true; end

	# If the button area (rectangle) has been clicked on change the background color
	# also store the mouse_x and mouse_y attributes that we 'inherit' from Gosu
	# you will learn about inheritance in the OOP unit - for now just accept that
	# these are available and filled with the latest x and y locations of the mouse click.

	def button_down(id)
		case id
	    when Gosu::MsLeft
	    	# What should happen here?
			if(@page==Page::HOME)
				if area_clicked(MENU_INTERFACE2_X, MENU_INTERFACE_Y, MENU_INTERFACE2_X+MENU_WIDTH, MENU_INTERFACE_Y+MENU_HEIGHT)
					@page=Page::LIBRARY
					return
				end
				#Check which album is clicked
				j=0
				count=@albums.length()
				while j<count
					artwork_coordinate=@albums[j].artwork.dim
					if area_clicked(artwork_coordinate.leftX, artwork_coordinate.topY, artwork_coordinate.rightX, artwork_coordinate.bottomY)
						@album_current_playing=j
						@track_current_playing=-1 #when change album, the current album playing marks wont appear
						#@song=nil #prevent the song from keep playing when the user change album suddenly
						break
					end
					j+=1
				end

				#puts @album_current_playing
				#when the album is selected
				if @album_current_playing>=0
					#Check which track is clicked
					i=0
					count=@albums[@album_current_playing].tracks.length()
					while i<count
						album=@albums[@album_current_playing]
						track_coordinate=album.tracks[i].dim
						if area_clicked(track_coordinate.leftX, track_coordinate.topY, track_coordinate.rightX, track_coordinate.bottomY)
							playTrack(album.tracks[i].location)
							@track_current_playing=i
							@liked_track_current_playing=-1 #when the user change from hearing the song from playlist to main page
							#puts @track_current_playing
							break
						end
						i+=1
					end

					user_interaction()

				end

			elsif(@page==Page::LIBRARY)
				if(@library_page==Library::ALLSONG)
					count=@songs.length

					i=0
					while(i<count)
						song_coordinate=@songs[i].dim
						if area_clicked(song_coordinate.leftX, song_coordinate.topY, song_coordinate.rightX, song_coordinate.bottomY)
							flag=1

							#puts @songs[i].name

							@song_choosed=@songs[i].name
							#puts @song_choosed
							#puts @liked_song.length

							#check if the song choosed are selected before or not
							j=0
							while(j<@liked_song.length)
								if(@song_choosed==@liked_song[j])
									flag=0
									break
								end
								j+=1
							end

							if(flag==1)
								@liked_song<<@song_choosed
								@added_to_playlist<<i
							end
							break
						end
						i+=1
					end
				end

				if(@library_page==Library::PLAYLIST)
					i=0
					count=@liked_song.length
					#puts "count" + count.to_s
					
					while(i<count)
						song_coordinate=@liked_songs_data[i].dim
						#puts song_coordinate.topY
						if area_clicked(song_coordinate.leftX, song_coordinate.topY, song_coordinate.rightX, song_coordinate.bottomY)
							playTrack(@liked_songs_data[i].location)
							@liked_track_current_playing=i
							#puts "track playing is:" + i.to_s
							@auto_running=1
							@track_current_playing=-1 #when the user change song from main page to playlist

							
							break
						end
						i+=1
					end

					user_interaction()

				end

				if area_clicked(FEATURE_INTERFACE1_X, FEATURE_INTERFACE_Y, FEATURE_INTERFACE1_X+FEATURE_WIDTH, FEATURE_INTERFACE_Y+FEATURE_HEIGHT)
					@library_page=Library::ALLSONG
					return
				elsif area_clicked(FEATURE_INTERFACE2_X, FEATURE_INTERFACE_Y, FEATURE_INTERFACE2_X+FEATURE_WIDTH, FEATURE_INTERFACE_Y+FEATURE_HEIGHT)
					@library_page=Library::PLAYLIST
					return
				end
				
				if area_clicked(MENU_INTERFACE1_X, MENU_INTERFACE_Y, MENU_INTERFACE1_X+MENU_WIDTH, MENU_INTERFACE_Y+MENU_HEIGHT)
					@page=Page::HOME
					return
				end
			end

	    end
	end
end

# Show is a method that loops through update and draw

MusicPlayerMain.new.show if __FILE__ == $0