A very simple discord bot to query the stormgate api.

[Click Here](https://discord.com/oauth2/authorize?&client_id=1204440376262398002&scope=bot) to invite to your server

**Leaderboard**

!!leaderboard will return the top 10 leaderboard entries (sorted by mmr)

![image](https://github.com/joshleblanc/stormgate-world-discord/assets/1729810/b74aef56-95e9-46e2-9d3d-9d102d7bff81)

**Search**

!!search <query> will return the closest matching player's leaderboard entries.

![image](https://github.com/joshleblanc/stormgate-world-discord/assets/1729810/2604d2e3-b427-43fa-8500-7f5d5ca12a7d)

**Around**

!!around <rank> will return the page the rank is on

![image](https://github.com/joshleblanc/stormgate-world-discord/assets/1729810/fdee5b67-e5d1-4c13-b034-a9ecbb67cfd7)

**Last**

!!last <query> will return the last match for the closest matching player, including finished and ongoing games

![image](https://github.com/joshleblanc/stormgate-world-discord/assets/1729810/4f2dce6b-0077-4eaf-9419-68267b1f53dd)

![image](https://github.com/joshleblanc/stormgate-world-discord/assets/1729810/98609c73-1378-4b93-ba48-ef1922bca072)


**Stats**

!!stats will return aggregate statistics
!!stats <league> will return aggregate statistics for a given league

![image](https://github.com/joshleblanc/stormgate-world-discord/assets/1729810/4099f7c0-f1e0-4308-a40f-ae533e46056c)


**Activity**

!!activity <query> will return aggregate activity statistics for the player

**Graph Commands**

The following graph commands are available to visualize player statistics:

`!!mmr_history <query>` - Shows MMR history over time for each faction
- Displays MMR trends for all factions the player has used
- Each faction is shown in its distinct color (Vanguard: Blue, Infernals: Red, Celestials: Purple)

`!!duration_stats <query>` - Shows win/loss distribution by game duration for each faction
- Displays how many games were won/lost at each duration
- Stacked bars show wins (darker) and losses (lighter) for each faction

`!!race_stats <query>` - Shows win rates against each opponent race for each faction
- Displays win rate percentages against different races
- Each faction's performance is shown in its distinct color

`!!map_stats <query>` - Shows win rates on different maps for each faction
- Displays win rates for the top 10 most played maps
- Each faction's performance is shown in its distinct color
- Maps are sorted by total games played

Note: If no stats are found or the account is private, the bot will let you know.
