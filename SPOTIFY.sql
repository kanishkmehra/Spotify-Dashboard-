-- Advanced SQL Project -- Spotify datasets

DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);

-- EDA 

SELECT COUNT (*) FROM SPOTIFY ;

SELECT COUNT(DISTINCT ARTIST) FROM SPOTIFY ;

SELECT COUNT(DISTINCT ALBUM ) FROM SPOTIFY ;

SELECT DISTINCT ALBUM_TYPE FROM SPOTIFY ;	

SELECT duration_min FROM SPOTIFY ;

SELECT MAX(duration_min) FROM SPOTIFY ;

SELECT MIN(duration_min) FROM SPOTIFY ;

SELECT * FROM SPOTIFY 
WHERE duration_min = 0 

DELETE FROM SPOTIFY 
WHERE duration_min = 0 

SELECT * FROM SPOTIFY 
WHERE duration_min = 0 

SELECT DISTINCT channel FROM SPOTIFY; 

SELECT DISTINCT most_played_on  FROM SPOTIFY; 

-- ------------------------------------------
-- DATA ANALYSIS -- EASY CATEGORY
-- ------------------------------------------

-- Q1 Retrieve the names of all tracks that have more than 1 billion streams.

SELECT * FROM SPOTIFY 
WHERE stream > 1000000000

-- Q2 List all albums along with their respective artists.

SELECT DISTINCT artist , album
FROM SPOTIFY
ORDER BY 1 ; 

-- Q3 Get the total number of comments for tracks where licensed = TRUE.

SELECT SUM(comments) as total_comments 
FROM SPOTIFY 
WHERE licensed = 'true'

-- Q4 Find all tracks that belong to the album type single.

SELECT * FROM SPOTIFY 
WHERE album_type = 'single'

-- Q5 Count the total number of tracks by each artist.

SELECT artist , count(*) as total_no_songs
FROM SPOTIFY 
GROUP BY artist 
ORDER BY 2 DESC ; 

----------------------------------------------
-- MEDIUM LEVEL
----------------------------------------------

-- Q6 Calculate the average danceability of tracks in each album.

SELECT album , AVG(danceability) as avg_danceability
FROM SPOTIFY 
GROUP BY 1 
ORDER BY 2 DESC ; 

-- Q7 Find the top 5 tracks with the highest energy values.

SELECT track , MAX(energy)
FROM SPOTIFY
GROUP BY 1 
ORDER BY 2 DESC 
LIMIT 5 ; 

-- Q8 List all tracks along with their views and likes where official_video = TRUE.

-- pick the highest single snapsot of views and likes per tracks.

SELECT track , MAX(views) AS max_views , MAX(likes) AS max_likes 
FROM SPOTIFY 
WHERE official_video = 'true'
GROUP BY track 
ORDER BY max_views DESC ; 

-- sum up all the snapshots of views and likes per tracks.

SELECT track , SUM(views) AS total_views , SUM(likes) AS total_likes
FROM SPOTIFY 
WHERE Official_video = 'true'
GROUP BY track
ORDER BY total_views DESC ; 

-- Q9 For each album, calculate the total views of all associated tracks.

SELECT album , SUM(views) AS total_album_views 
FROM SPOTIFY 
GROUP BY album 
ORDER BY total_album_views DESC ;

-- Q10 Retrieve the track names that have been streamed on Spotify more than YouTube. 

SELECT * FROM 
(SELECT track , COALESCE(SUM(CASE WHEN most_played_on = 'Youtube' THEN stream END ),0) AS stream_on_youtube ,
               COALESCE(SUM(CASE WHEN most_played_on = 'Spotify' THEN stream END ),0) AS stream_on_spotify
FROM SPOTIFY 
GROUP BY 1 ) AS T1
WHERE stream_on_spotify > stream_on_youtube
AND 
stream_on_youtube != 0

----------------------------------------------
-- HARD LEVEL
----------------------------------------------

/*Find the top 3 most-viewed tracks for each artist using window functions.
Write a query to find tracks where the liveness score is above the average.
Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.*/

-- Q11 Find the top 3 most-viewed tracks for each artist using window functions.

WITH ranking_artist
AS
(SELECT artist , track , SUM(views) AS total_view ,
DENSE_RANK() OVER( PARTITION BY artist ORDER BY SUM(views) DESC) AS rank
FROM SPOTIFY 
GROUP BY 1,2 
ORDER BY 1,3 DESC)

SELECT * FROM ranking_artist
WHERE rank <= 3 ;

-- Q12 Write a query to find tracks where the liveness score is above the average.

SELECT track , artist , liveness
FROM SPOTIFY
WHERE liveness > ( SELECT AVG(liveness)
                   FROM SPOTIFY )


-- Q13 Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.

WITH CTE AS 
(SELECT album , MAX(energy) AS highest_energy , MIN(energy) AS lowest_energy
FROM SPOTIFY 
GROUP BY 1 
)
SELECT album , highest_energy - lowest_energy AS energy_difference
FROM CTE 
ORDER BY 2 DESC ;  


-- Q14 Find tracks where the energy-to-liveness ratio is greater than 1.2.

SELECT energy , liveness , energy/liveness AS ratio
FROM SPOTIFY 
WHERE energy/liveness > 1.2 
ORDER BY 3 DESC ; 

-- Q15 Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.

SELECT 
    track,
    views,
    likes,
    SUM(likes) OVER (ORDER BY views) AS cumulative_likes
FROM spotify;
