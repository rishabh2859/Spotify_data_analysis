create table spotify_data(
     Artist	text,
	 Track	text,
	 Album	text,
	 Album_type	text,
	 Danceability	float,
	 Energy	float,
	 Loudness	float,
	 Speechiness	float,
	 Acousticness	float,
	 Instrumentalness	float,
	 Liveness	float,
	 Valence	float,
	 Tempo	float,
	 Duration_min	float,
	 Title	text,
	 Channel	text,
	 Views_   int,
	 Likes	int,
	 Comments_ int,
	 Licensed	text,
	 official_video	text,
	 Stream	 int,
	 EnergyLiveness	float,
	 most_playedon text
);
alter table spotify_data alter Views_ type bigint;
alter table spotify_data alter Likes type bigint;
alter table spotify_data alter Comments_ type bigint;
alter table spotify_data alter Stream type bigint;

select * from spotify_data;
--Retrieve the names of all tracks that have more than 1 billion streams.
select track from spotify_data
where Stream>1000000000;
--List all albums along with their respective artists.
select distinct artist,album from spotify_data;
--Get the total number of comments for tracks where licensed = TRUE
select track,sum(Comments_) as total_comments from spotify_data
where Licensed='TRUE'
group by 1;
--Find all tracks that belong to the album type single.
select track from spotify_data 
where album_type='single';
--Count the total number of tracks by each artist.
select artist,count(track) as total_songs from spotify_data
group by 1 order by 2;
--Calculate the average danceability of tracks in each album.
select album,track,avg(Danceability) from spotify_data
group by 1,2 order by 1;
--Find the top 5 tracks with the highest energy values.
select track,energy from spotify_data
order by 2 desc limit 5;
--List all tracks along with their views and likes where official_video = TRUE
select track,Views_,Likes,official_video from spotify_data
where official_video='TRUE';
--For each album, calculate the total views of all associated tracks.
select album,track,sum(Views_) as total_views from spotify_data
group by 1,2;
--Retrieve the track names that have been streamed on Spotify more than YouTube.
select track,most_playedon from spotify_data
where most_playedon='Spotify';
--Find the top 3 most-viewed tracks for each artist using window functions.
with cte as(select artist,track,dense_rank() over(partition by artist order by Views_ desc) as ranks,Views_
from spotify_data)
select * from cte where ranks<=3;
--Write a query to find tracks where the liveness score is above the average.
select track,liveness from spotify_data
where liveness>(select avg(liveness) from spotify_data) order by 2;
--Use a WITH clause to calculate the difference between the highest 
--and lowest energy values for tracks in each album.
with cte as(
select album,track,energy from spotify_data
order by 3 desc
)
select album,max(energy)-min(energy) as diff from cte
group by 1 order by 2 desc;
--Find tracks where the energy-to-liveness ratio is greater than 1.2.
select * from(select track,energy,liveness,(energy/liveness) as ratio from spotify_data
where liveness!=0) as new_data
where ratio>1.2 order by ratio;
--Calculate the cumulative sum of likes for tracks ordered by the number of views,
--using window functions.
select track,Views_,Likes,sum(Likes) over(order by Views_)
from spotify_data;
--Query Optimization
create index artist_index on spotify_data(artist);
explain analyze
select artist,track,Views_ from spotify_data where artist='Gorillaz' and most_playedon='Youtube'
order by stream desc limit 25;
