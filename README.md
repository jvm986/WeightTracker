# WeightTracker

A simple implementation of `CoreBluetooth` to connect to the `Mi Body Composition Scale 2` and display weight and body fat percentage data.

Main Screen|Manual Entry|User Data
:-:|:-:|:-:
<img src="https://user-images.githubusercontent.com/20093619/192139552-42ed10a0-e97f-47ea-b373-e7fb2cd25cae.png" width="300">  |  <img src="https://user-images.githubusercontent.com/20093619/192139752-64af88bb-8317-46d5-8f7f-615df4c9bdb1.png" width="300"> | <img src="https://user-images.githubusercontent.com/20093619/192139754-3bcc89a5-cc6f-499a-81f4-7a7279022879.png" width="300">

Conceptually, the idea is that when managing weight loss / gain one does not want to be discourgaged by fluctuations over the course of a week but does want an accurate estimation of weight. WeightTracker obfuscates individual points of data and only shows the user a rolling 7-day average of weight and body fat percentage.

### To Do:
- Unit Tests
- Error Handling
- Manage Units (kg vs lb)
- Manage lbm table (currently hard-coded)
- Scrollable trend view / range selection
