
--create showcase schema
create schema voronoi_showcase;

--create table for position sample data
create table voronoi_showcase.match_position
	(
	MATCH_ID		varchar(100),
	MATCH_SECTION	varchar(100),
	TEAM_ID			varchar(100),
	PERSON_ID		varchar(100),
	FRAME_ID		decimal(7,0),
	FRAME_TIMESTAMP	timestamp,
	FRAME_X			decimal(5,2),
	FRAME_Y			decimal(5,2)
	);

--import position sample data
import into voronoi_showcase.match_position
	from local csv file 'c:\temp\position_example.csv'
	column separator = ';';
