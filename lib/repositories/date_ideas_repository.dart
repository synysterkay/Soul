import 'package:soul_plan/services/date_idea_service.dart';
import 'dart:math';

class DateIdeasRepository {
  static Set<String> _usedRandomIdeas = {};
  static final Map<String, List<String>> _dateIdeas = {
    'Energized_Energized': [
      'Adventure Park Exploration',
      'Dance Class Together',
      'Rock Climbing Challenge',
      'Bike Ride and Picnic',
      'Escape Room Adventure',
      'Trampoline Park Date',
      'Beach Volleyball Match',
      'Hiking to a Waterfall',
      'Kayaking Adventure',
      'Laser Tag Competition',
    ],
    'Energized_Calm': [
      'Cooking Class Experience',
      'Art Gallery Tour',
      'Sunset Hike',
      'Gentle Kayaking Trip',
      'Board Game Café Visit',
      'Farmers Market Exploration',
      'Botanical Garden Tour',
      'Pottery Class Together',
      'Photography Walk',
      'Bookstore Café Date',
    ],
    'Calm_Calm': [
      'Stargazing Picnic',
      'Spa Day Together',
      'Wine Tasting Experience',
      'Bookstore and Café Visit',
      'Yoga Session for Two',
      'Tea Tasting Journey',
      'Painting and Wine Night',
      'Sunset Beach Walk',
      'Couples Massage Day',
      'Cozy Movie Marathon',
    ],
    'Stressed_any': [
      'Meditation Retreat',
      'Nature Walk and Picnic',
      'Couples Massage Experience',
      'Relaxing Music Concert',
      'Pottery Class Therapy',
      'Floating Therapy Session',
      'Gentle Yoga Together',
      'Aromatherapy Workshop',
      'Scenic Drive Adventure',
      'Garden Visit and Tea',
    ],
    'Excited_any': [
      'Mystery Date Adventure',
      'Food Tour Experience',
      'Amusement Park Day',
      'Comedy Show Night',
      'Karaoke Evening',
      'Surprise Destination Trip',
      'Festival or Fair Visit',
      'Live Music Concert',
      'Sports Game Attendance',
      'Themed Party Night',
    ],
    'Tired_any': [
      'Cozy Movie Marathon',
      'Scenic Drive Adventure',
      'Relaxing Picnic Date',
      'Book Reading Together',
      'Stargazing Evening',
      'Breakfast in Bed Morning',
      'Hammock and Audiobook',
      'Sunset Watching',
      'Gentle Boat Ride',
      'Café Hopping Day',
    ],
    'default': [
      'New Restaurant Discovery',
      'Museum Exploration',
      'Cooking Class Together',
      'Nature Walk Adventure',
      'Local Event Attendance',
      'Dessert Tasting Tour',
      'Rooftop Bar Sunset',
      'Arcade Game Challenge',
      'Bowling Night Fun',
      'Mini Golf Adventure',
    ],
  };

  // Add a method to get a formatted date idea with all sections
  static String getFormattedDateIdea(String ideaTitle, List<String> categories) {
    final placeTypes = DateIdeaService.getRelevantPlaceTypes(categories);
    final placeSuggestions = placeTypes.take(3).join(', ');
    final Map<String, Map<String, String>> dateContent = {
    'Adventure Park Exploration': {
    'introduction': 'Get your adrenaline pumping with an exciting day at an adventure park! This energetic date combines thrills, laughter, and the chance to challenge yourselves together.',
    'steps': '1. Research adventure parks in your area with good reviews\n2. Choose activities you both feel comfortable trying\n3. Arrive early to avoid crowds and maximize your time\n4. Start with easier challenges before moving to more difficult ones\n5. Take breaks to hydrate and rest between activities\n6. Celebrate your achievements with a treat afterward',
    'touches': '- Pack a small first aid kit with bandages and pain relievers\n- Bring a waterproof camera to capture action shots\n- Wear matching outfits or accessories for fun photos\n- Prepare a "courage award" to give your partner afterward',
    'conversation': '- Discuss which activities pushed you outside your comfort zone\n- Share stories about childhood adventures and thrills\n- Talk about other adventure activities you\'d like to try together',
    'preparation': 'Wear comfortable athletic clothes and closed-toe shoes. Check weather forecasts and park policies beforehand. This date can be adapted by choosing less intense activities if energy levels are lower, or focusing on spectating and enjoying the atmosphere if one partner is less adventurous.'
    },
    'Dance Class Together': {
    'introduction': 'Step into the rhythm of romance with a dance class for two! Learning to move together creates a unique bond and gives you skills you can enjoy for years to come.',
    'steps': '1. Find a beginner-friendly dance class in a style you both find interesting\n2. Register in advance as couples classes often fill up quickly\n3. Wear comfortable clothes and appropriate shoes\n4. Arrive early to meet the instructor and get comfortable\n5. Focus on having fun rather than perfect technique\n6. Practice your new moves together after class',
    'touches': '- Create a playlist of songs that match the dance style you learned\n- Bring a change of nice clothes for dinner after class\n- Record a short video of what you learned to watch later\n- Find a local spot where you can use your new dance skills',
    'conversation': '- Discuss which partner naturally takes the lead in dancing and life\n- Share memories of dancing at previous events in your lives\n- Talk about cultures associated with the dance style you\'re learning',
    'preparation': 'Check if the dance studio provides shoes or if you need to bring specific footwear. Eat lightly before class. This date can be adapted by choosing a virtual class if you prefer privacy, or selecting a less physically demanding dance style if energy levels are lower.'
    },
    'Rock Climbing Challenge': {
    'introduction': 'Challenge yourselves with an exhilarating rock climbing adventure! This date offers the perfect mix of physical challenge, trust-building, and the satisfaction of conquering heights together.',
    'steps': '1. Find a climbing gym that offers beginner routes and equipment rental\n2. Book a beginner lesson if you\'re new to climbing\n3. Listen carefully to safety instructions and proper techniques\n4. Start with easier routes to build confidence\n5. Take turns climbing and belaying (supporting) each other\n6. Celebrate each successful climb, no matter how small',
    'touches': '- Bring chalk for your hands to improve grip\n- Take photos of each other conquering difficult routes\n- Create custom "achievement badges" to award each other\n- Pack protein-rich snacks to refuel your energy',
    'conversation': '- Talk about how it feels to literally put your safety in your partner\'s hands\n- Discuss how you each approach challenges and fears\n- Share other physical challenges you\'d like to overcome together',
    'preparation': 'Wear flexible, comfortable clothing and bring water bottles. Trim your fingernails before climbing. This date can be adapted by choosing bouldering (lower climbing without ropes) if you\'re concerned about heights, or by simply watching and encouraging if one partner doesn\'t want to climb.'
    },
    'Bike Ride and Picnic': {
    'introduction': 'Combine the joy of exploration with the pleasure of outdoor dining on this bike ride and picnic date. Feel the breeze in your hair as you discover new paths before settling down for a romantic meal in nature.',
    'steps': '1. Plan a scenic bike route with a beautiful picnic destination\n2. Check that both bikes are in good working condition\n3. Pack a picnic in a backpack that\'s easy to carry while riding\n4. Bring a blanket and portable speakers for ambiance\n5. Take your time enjoying the journey, stopping at interesting spots\n6. Set up your picnic in a scenic, somewhat private location',
    'touches': '- Include some surprise favorite treats your partner doesn\'t expect\n- Bring a small vase with a flower for the picnic setup\n- Pack a card game or small activity to enjoy after eating\n- Take a selfie in the same spot to create a tradition for future rides',
    'conversation': '- Share childhood memories of bike riding or picnics\n- Discuss your favorite outdoor experiences together\n- Plan future bike routes you\'d like to explore together',
    'preparation': 'Check the weather forecast and pack accordingly. Bring sunscreen, bug spray, and a basic bike repair kit. This date can be adapted by choosing an easier route or renting electric bikes if energy levels are lower, or by driving to the picnic spot if biking isn\'t possible.'
    },
    'Escape Room Adventure': {
    'introduction': 'Put your teamwork and problem-solving skills to the test with an exciting escape room challenge! This immersive experience will have you working together against the clock in a thrilling scenario.',
    'steps': '1. Research escape rooms in your area and choose a theme you both enjoy\n2. Book in advance as popular rooms fill up quickly\n3. Arrive 15 minutes early for instructions and setup\n4. Communicate clearly and share all clues you find\n5. Divide tasks based on your individual strengths\n6. Celebrate afterward whether you escape or not',
    'touches': '- Dress in theme with the escape room for added fun\n- Create team name and matching accessories\n- Take a victory (or valiant attempt) photo afterward\n- Prepare a small prize to give your partner regardless of outcome',
    'conversation': '- Discuss how you each approach puzzles and problems\n- Talk about how your different thinking styles complement each other\n- Share what you learned about each other during the challenge',
    'preparation': 'Eat before you go and use the restroom before starting. Wear comfortable clothes and avoid bringing unnecessary items as storage may be limited. This date can be adapted by choosing a less challenging room if you\'re beginners, or by finding a virtual escape room you can do from home.'
    },
    'Trampoline Park Date': {
    'introduction': 'Rediscover your playful side with a high-energy date at a trampoline park! Bounce, flip, and laugh together in this gravity-defying playground for adults.',
    'steps': '1. Find a trampoline park with good safety ratings and varied activities\n2. Book a session during less crowded hours if possible\n3. Wear appropriate athletic clothing and bring grip socks\n4. Start with basic bouncing before trying more advanced moves\n5. Try different activities like dodgeball, foam pits, or obstacle courses\n6. Take breaks to rest and hydrate between jumping sessions',
    'touches': '- Challenge each other to silly trampoline contests\n- Record slow-motion videos of your best jumps and flips\n- Bring a change of clothes for after your workout\n- Plan for a refreshing smoothie or treat afterward',
    'conversation': '- Share memories of playground adventures from childhood\n- Discuss how it feels to let go of adult seriousness and play\n- Talk about other playful activities you\'d enjoy trying together',
    'preparation': 'Remove jewelry and empty pockets before jumping. Avoid eating a heavy meal beforehand. This date can be adapted by focusing on gentler bouncing or watching others if energy levels are lower, or by trying a different physical activity if trampolines aren\'t appealing.'
    },
    'Beach Volleyball Match': {
    'introduction': 'Dig your toes in the sand and spike your way to a memorable date with beach volleyball! This active, sun-soaked experience combines friendly competition with beachside relaxation.',
    'steps': '1. Find a beach with volleyball nets or bring a portable net\n2. Bring a good quality volleyball and extra air pump\n3. Arrive early to secure a court during busy times\n4. Start with a warm-up and practice basic passes\n5. Play a friendly match or join others for a group game\n6. Cool down with a refreshing swim afterward',
    'touches': '- Create team shirts or matching bandanas\n- Bring a waterproof bluetooth speaker for energizing music\n- Pack a cooler with cold drinks and fruit for breaks\n- Prepare a silly trophy for the winner',
    'conversation': '- Discuss your experiences with team sports growing up\n- Talk about how you each handle competition\n- Share other beach activities you\'d like to try together',
    'preparation': 'Apply sunscreen generously and bring hats and sunglasses. Pack beach chairs and an umbrella for breaks. This date can be adapted by playing a less intense game like beach paddleball if volleyball is too strenuous, or by enjoying beach games that don\'t require as much running.'
    },
    'Hiking to a Waterfall': {
    'introduction': 'Embark on a refreshing journey through nature to discover a breathtaking waterfall! This adventure combines the satisfaction of a good hike with the magical reward of a natural wonder.',
    'steps': '1. Research local waterfall hikes suitable for your experience level\n2. Check trail conditions and weather before heading out\n3. Pack essentials like water, snacks, and a first aid kit\n4. Start early to avoid crowds and afternoon heat\n5. Take your time on the trail, noticing wildlife and plants\n6. Spend time relaxing and enjoying the waterfall when you arrive',
    'touches': '- Bring a waterproof camera or phone case for waterfall photos\n- Pack a small towel if swimming is allowed at the base\n- Prepare a special trail mix with both your favorite nuts and dried fruits\n- Bring a small waterproof blanket to sit near the falls',
    'conversation': '- Share your favorite natural wonders you\'ve experienced\n- Discuss how being in nature affects your mood and perspective\n- Talk about future hiking adventures you\'d like to experience together',
    'preparation': 'Wear proper hiking shoes and layered clothing. Check if the trail requires a permit. This date can be adapted by choosing a shorter, easier trail if energy levels are lower, or by finding a waterfall with road access if hiking isn\'t possible.'
    },
    'Kayaking Adventure': {
    'introduction': 'Paddle your way to romance with a kayaking adventure on calm waters! This peaceful yet active date lets you explore shorelines and waterways while working together in sync.',
    'steps': '1. Find a kayak rental location with scenic routes\n2. Choose between single kayaks or a tandem kayak for two\n3. Get proper instruction and safety equipment before setting out\n4. Start with a shorter route if you\'re beginners\n5. Take breaks to float, observe wildlife, and take photos\n6. Pack a waterproof bag with snacks and water for a floating picnic',
    'touches': '- Bring a waterproof speaker for gentle background music\n- Pack a surprise waterproof disposable camera\n- Prepare a special water bottle with fruit infusion\n- Bring a change of clothes for after your paddle',
    'conversation': '- Talk about your experiences with water activities growing up\n- Discuss how it feels to work together to navigate\n- Share other bodies of water you\'d like to explore together',
    'preparation': 'Apply waterproof sunscreen and wear clothes that can get wet. Bring a dry bag for phones and valuables. This date can be adapted by choosing a guided tour if you\'re less experienced, or by opting for a pedal boat if kayaking seems too strenuous.'
    },
    'Laser Tag Competition': {
    'introduction': 'Step into a high-energy world of lights, strategy, and friendly competition with laser tag! This immersive game lets you team up or face off in an exciting, adrenaline-pumping environment.',
    'steps': '1. Find a laser tag facility with good reviews and varied arena designs\n2. Wear dark, comfortable clothing that allows easy movement\n3. Listen carefully to the game rules and equipment instructions\n4. Develop a strategy together if playing as a team\n5. Play multiple rounds to try different approaches\n6. Check your scores and celebrate improvement with each game',
    'touches': '- Create team code names and hand signals\n- Design matching wristbands or temporary tattoos\n- Take victory poses for photos after each round\n- Prepare a playful "champion" certificate for afterward',
    'conversation': '- Discuss your different strategic approaches to the game\n- Talk about how you each handle competitive situations\n- Share other arcade or active games you\'d like to try together',
    'preparation': 'Eat a light meal beforehand and stay hydrated. Wear comfortable shoes with good grip. This date can be adapted by focusing on teamwork rather than competition if that\'s more comfortable, or by trying a different arcade game if laser tag is too intense.'
    },
    'Cooking Class Experience': {
    'introduction': 'Spice up your relationship with a hands-on cooking class where you\'ll learn new culinary skills together! This delicious date combines creativity, teamwork, and the reward of enjoying your creation.',
    'steps': '1. Find a cooking class featuring cuisine you both want to learn\n2. Register in advance as popular classes fill quickly\n3. Arrive hungry but not starving\n4. Take turns with different cooking tasks\n5. Ask questions and take notes for recreating dishes later\n6. Savor the meal you\'ve prepared together',
    'touches': '- Bring a small notebook to write down tips and recipe variations\n- Take photos of each cooking stage to remember the process\n- Purchase a special ingredient or tool used in class to use at home\n- Wear matching aprons if you have them',
    'conversation': '- Share family cooking traditions and favorite meals growing up\n- Discuss your kitchen dynamics and how you collaborate\n- Talk about other cuisines you\'d like to learn together',
    'preparation': 'Check if you need to bring anything specific. Wear comfortable shoes as cooking classes often involve standing for extended periods. This date can be adapted by finding a virtual cooking class to do at home, or by choosing a demonstration class with less hands-on work if you prefer.'
    },
    'Art Gallery Tour': {
    'introduction': 'Immerse yourselves in creativity and culture with an art gallery tour! This thoughtful date offers beautiful visuals, interesting conversations, and a glimpse into each other\'s aesthetic preferences.',
    'steps': '1. Research galleries featuring exhibitions that might interest you both\n2. Check for special events like opening nights or artist talks\n3. Start with smaller galleries before moving to larger museums\n4. Take your time in each room, focusing on pieces that catch your eye\n5. Share your impressions without worrying about art expertise\n6. Visit the gallery café or gift shop to extend the experience',
    'touches': '- Purchase a small art print or postcard as a memento\n- Take photos of each other with favorite artworks\n- Bring a small notebook to sketch or write impressions\n- Research one interesting fact about the featured artist beforehand',
    'conversation': '- Discuss which pieces resonate with you and why\n- Share how different art styles make you feel\n- Talk about art or creativity in your own lives and upbringing',
    'preparation': 'Check gallery policies on photography and bags. Wear comfortable shoes as gallery viewing involves lots of standing and walking. This date can be adapted by visiting a virtual gallery online, or by focusing on a specific exhibition section if time or energy is limited.'
    },
    'Sunset Hike': {
    'introduction': 'Experience the magic of nature\'s most beautiful light show with a sunset hike! This romantic adventure combines gentle exercise with breathtaking views as day transforms into evening.',
    'steps': '1. Choose a west-facing trail with a good viewpoint for sunset\n2. Check sunset time and plan to arrive at the viewpoint 30 minutes early\n3. Pack headlamps or flashlights for the return journey\n4. Bring a light jacket as temperatures often drop after sunset\n5. Find a comfortable spot with an unobstructed view\n6. Stay for the afterglow which can be as beautiful as the sunset itself',
    'touches': '- Pack a thermos with hot chocolate or tea to share\n- Bring a lightweight blanket to sit on or wrap around shoulders\n- Take a "same place, different light" photo series as the sun sets\n- Prepare a special sunset-colored treat like orange and red fruits',
    'conversation': '- Share your favorite times of day and why they appeal to you\n- Discuss memorable sunsets you\'ve experienced in your lives\n- Talk about places around the world known for beautiful sunsets',
    'preparation': 'Check trail difficulty and estimated hiking time. Always tell someone where you\'re going and when you expect to return. This date can be adapted by driving to a scenic overlook if hiking isn\'t possible, or by watching sunset from a city viewpoint if you prefer an urban setting.'
    },
    'Gentle Kayaking Trip': {
    'introduction': 'Glide peacefully across calm waters with a gentle kayaking trip for two! This serene yet active date lets you connect with nature and each other while enjoying beautiful shoreline views.',
    'steps': '1. Find a kayak rental on a calm lake, slow river, or protected bay\n2. Choose between single kayaks or a tandem kayak for two\n3. Get proper instruction and wear life jackets\n4. Paddle at a leisurely pace, taking time to observe surroundings\n5. Find a quiet cove or beach for a short break\n6. Watch for wildlife like birds, turtles, or fish',
    'touches': '- Bring a waterproof camera or phone case for photos\n- Pack a small waterproof bag with snacks and drinks\n- Prepare a waterproof map with interesting landmarks marked\n- Bring polarized sunglasses to better see into the water',
    'conversation': '- Discuss how being on water makes you feel\n- Share stories of memorable experiences in nature\n- Talk about other water activities you might enjoy together',
    'preparation': 'Apply waterproof sunscreen and wear a hat. Bring a change of clothes in case you get wet. This date can be adapted by choosing a guided tour if you\'re less experienced, or by opting for a canoe or rowboat if that feels more stable.'
    },
    'Board Game Café Visit': {
    'introduction': 'Unleash your playful competitive spirit at a board game café! This entertaining date combines the fun of gaming with cozy café vibes for hours of strategic thinking and laughter.',
    'steps': '1. Find a board game café with good reviews and a large game selection\n2. Arrive during less busy hours for better game availability\n3. Ask staff for game recommendations based on your interests\n4. Start with a shorter game to warm up\n5. Order drinks and snacks to enjoy while playing\n6. Try games of different styles – cooperative, strategic, and silly',
    'touches': '- Take a "victory pose" photo after each game\n- Create a scoreboard to track wins across multiple games\n- Bring a small prize for the overall winner\n- Ask if you can reserve a special table or corner',
    'conversation': '- Discuss your game-playing history and family traditions\n- Talk about how you each handle winning and losing\n- Share what your game choices reveal about your personalities',
    'preparation': 'Check if the café requires reservations. Consider looking at their game library online beforehand to identify options. This date can be adapted by bringing your own games to a regular café if a board game café isn\'t available, or by choosing simpler games if you\'re tired or short on time.'
    },
    'Farmers Market Exploration': {
    'introduction': 'Wander through stalls of fresh produce, artisanal foods, and handcrafted goods at a local farmers market! This sensory-rich date combines culinary discovery with supporting local businesses.',
    'steps': '1. Check market hours and arrive early for the best selection\n2. Bring reusable bags and small bills for purchases\n3. Start with a lap around the entire market to see what\'s available\n4. Sample offerings and talk with vendors about their products\n5. Choose ingredients together for a meal you\'ll cook later\n6. Find a spot to enjoy any ready-to-eat treats you purchased',
    'touches': '- Challenge each other to find the most unusual vegetable or fruit\n- Buy a small bouquet of fresh flowers or a potted herb\n- Select a local artisanal product to try for the first time\n- Take photos of the most colorful market displays',
    'conversation': '- Discuss your favorite seasonal foods and family recipes\n- Share memories of markets or food shopping experiences\n- Talk about sustainable food practices that interest you',
    'preparation': 'Eat a light meal beforehand so you\'re not too hungry for sampling. Bring a cooler bag if you plan to buy perishables. This date can be adapted by focusing on just one section of a larger market if time is limited, or by visiting an indoor market in bad weather.'
    },
    'Botanical Garden Tour': {
    'introduction': 'Immerse yourselves in a world of natural beauty with a visit to a botanical garden! This peaceful date surrounds you with stunning plants, fragrant flowers, and tranquil landscapes.',
    'steps': '1. Check the garden website for special exhibitions or blooming highlights\n2. Consider guided tour options or audio guides if available\n3. Pick up a map and plan your route through different sections\n4. Take your time in each area, noticing details and reading placards\n5. Find a quiet bench in your favorite section to sit and talk\n6. Visit the garden shop for a plant or seed packet to grow at home',
    'touches': '- Bring a plant identification app to learn more about favorites\n- Take close-up photos of interesting textures and patterns\n- Prepare a small sketchbook to draw particularly beautiful specimens\n- Research the language of flowers and share meanings of ones you see',
    'conversation': '- Discuss which environments and plants you\'re drawn to\n- Share memories of gardens or plants from your childhood\n- Talk about how different landscapes make you feel',
    'preparation': 'Check weather and dress accordingly. Wear comfortable walking shoes and bring water. This date can be adapted by using a wheelchair-accessible route if needed, or by focusing on indoor conservatories if weather is poor or energy is limited.'
    },
    'Pottery Class Together': {
    'introduction': 'Get your hands dirty and creativity flowing with a pottery class for two! This tactile date offers the satisfaction of creating something beautiful together while learning an ancient craft.',
    'steps': '1. Find a pottery studio offering beginner-friendly classes\n2. Register in advance as classes often have limited spots\n3. Wear clothes you don\'t mind getting clay on\n4. Listen carefully to techniques and start with basic forms\n5. Help each other troubleshoot challenges\n6. Make arrangements to pick up your fired pieces later',
    'touches': '- Take "clay-covered hands" photos during the process\n- Make something that can be used together, like matching mugs\n- Write a secret message on the bottom of your creation\n- Bring a small treat to enjoy during a break',
    'conversation': '- Discuss how it feels to create something with your hands\n- Share other creative activities you\'ve enjoyed or want to try\n- Talk about where you might display or how you\'ll use your creations',
    'preparation': 'Remove rings and bracelets before class. Bring a nail brush for cleaning under fingernails afterward. This date can be adapted by choosing a one-time workshop rather than a series if time is limited, or by selecting a different craft class if pottery doesn\'t appeal.'
    },
    'Photography Walk': {
    'introduction': 'See the world through new eyes with a photography walk date! This creative adventure encourages you to notice details, find beauty in the ordinary, and capture memories together.',
    'steps': '1. Choose an interesting area with varied visual elements\n2. Bring cameras or use smartphone cameras\n3. Decide on an optional theme like "textures" or "hidden beauty"\n4. Take turns photographing each other in interesting settings\n5. Challenge each other to find unusual perspectives\n6. Review your photos together over coffee afterward',
    'touches': '- Create a shared online album with your favorite shots\n- Prepare a small photography "scavenger hunt" list\n- Bring a portable printer to create instant prints\n- Plan to frame or print your favorite photo as a memento',
    'conversation': '- Discuss what catches each of your eyes and why\n- Share how photography has been part of your lives\n- Talk about places you\'d love to photograph together',
    'preparation': 'Charge camera batteries and bring memory cards. Check weather and dress accordingly. This date can be adapted by choosing an indoor location like a museum if weather is poor, or by shortening the route if time or energy is limited.'
    },
    'Bookstore Café Date': {
    'introduction': 'Combine the pleasure of books with the comfort of coffee on this relaxed bookstore café date! Browse interesting titles, discover new authors, and enjoy intimate conversations in a cozy atmosphere.',
    'steps': '1. Find an independent bookstore with a café or one near a good coffee shop\n2. Start by browsing separately to find books that interest you\n3. Choose one book you think your partner would enjoy\n4. Meet at the café to share your discoveries over drinks\n5. Read interesting passages to each other\n6. Consider purchasing a book to read together',
    'touches': '- Write a sweet note on a bookmark to place in a book you recommend\n- Take a "what we\'re reading" photo together\n- Create a list of books you both want to read\n- Find a book that relates to your relationship or shared interests',
    'conversation': '- Discuss books that have influenced your thinking\n- Share your reading habits and preferences\n- Talk about fictional characters you relate to or admire',
    'preparation': 'Check bookstore hours and any café seating policies. Bring reading glasses if needed. This date can be adapted by focusing on a specific section of the bookstore if time is limited, or by visiting a library instead if you prefer not to purchase books.'
    },
    'Stargazing Picnic': {
    'introduction': 'Experience the wonder of the night sky with a romantic stargazing picnic! This magical date combines delicious food with the awe-inspiring beauty of stars, planets, and constellations.',
    'steps': '1. Check weather and moonphase for optimal viewing conditions\n2. Find a location away from city lights with open sky views\n3. Bring a comfortable blanket and pillows\n4. Pack a picnic with easy-to-eat foods and warm drinks\n5. Download a stargazing app to identify celestial objects\n6. Allow time for your eyes to adjust to the darkness',
    'touches': '- Bring a thermos of hot chocolate or tea with cinnamon sticks\n- Pack glow sticks for subtle lighting\n- Create a playlist of space-themed or dreamy music\n- Bring binoculars or a portable telescope if available',
    'conversation': '- Share childhood memories of looking at the night sky\n- Discuss how the vastness of space makes you feel\n- Talk about space exploration and what you find fascinating about it',
    'preparation': 'Bring extra layers as temperatures drop at night. Check for local stargazing events or meteor showers. This date can be adapted by stargazing from a balcony or yard if travel isn\'t possible, or by visiting a planetarium if weather is poor.'
    },
    'Spa Day Together': {
    'introduction': 'Indulge in relaxation and rejuvenation with a spa day for two! This pampering date offers the perfect opportunity to unwind, de-stress, and enjoy peaceful quality time together.',
    'steps': '1. Research spas with couples packages or facilities\n2. Book treatments in advance, considering each other\'s preferences\n3. Arrive early to enjoy amenities like saunas or pools\n4. Drink plenty of water before and after treatments\n5. Take time to relax together in quiet spaces\n6. Extend the relaxation by having a light, healthy meal afterward',
    'touches': '- Bring comfortable sandals and robes if the spa doesn\'t provide them\n- Create a relaxing playlist to listen to while getting ready\n- Exchange small massages for each other before bed that night\n- Purchase a scented candle or bath product to continue the spa feeling at home',
    'conversation': '- Discuss how you each prefer to relax and unwind\n- Share self-care practices that are important to you\n- Talk about how physical wellness connects to mental wellbeing',
    'preparation': 'Avoid caffeine before your visit. Skip shaving right before treatments. This date can be adapted by creating a DIY spa day at home with face masks and massage, or by choosing just one treatment each if a full spa day isn \'t feasible.'
    },
    'Wine Tasting Experience': {
    'introduction': 'Delight your senses with a wine tasting experience that explores different flavors, aromas, and winemaking traditions! This sophisticated date offers both education and enjoyment in a beautiful setting.',
    'steps': '1. Research wineries or tasting rooms in your area\n2. Consider a guided tasting flight for the full experience\n3. Start with lighter wines before moving to fuller-bodied options\n4. Take notes on your favorites and why you enjoy them\n5. Ask questions about the winemaking process\n6. Purchase a bottle of your mutual favorite to enjoy later',
    'touches': '- Bring a small notebook to record tasting notes\n- Take photos of labels you enjoy for future reference\n- Learn a proper toast in another language\n- Pack crackers or bring mints to cleanse your palate',
    'conversation': '- Discuss your wine preferences and how they differ\n- Share memorable meals or occasions involving wine\n- Talk about regions or countries you\'d like to visit for their wine',
    'preparation': 'Arrange transportation if you\'ll be consuming alcohol. Eat a light meal beforehand. This date can be adapted by doing a non-alcoholic beverage tasting like tea or craft sodas, or by creating a DIY wine tasting at home with a few selected bottles.'
    },
    'Yoga Session for Two': {
    'introduction': 'Connect mind, body, and spirit with a yoga session designed for couples! This mindful date promotes flexibility, balance, and a sense of peaceful connection with each other.',
    'steps': '1. Find a yoga studio offering couples or beginner-friendly classes\n2. Arrive early to set up your mats and meet the instructor\n3. Focus on your breathing and being present\n4. Try partner poses that require cooperation and trust\n5. Support each other in challenging positions\n6. Enjoy the final relaxation pose together',
    'touches': '- Bring your own matching yoga mats if you have them\n- Prepare infused water with cucumber or fruit to share after class\n- Give each other a gentle hand or foot massage during final relaxation\n- Take a "yoga pose" photo together to remember the experience',
    'conversation': '- Discuss how the practice made you feel physically and mentally\n- Share other mindfulness practices you\'ve tried or want to explore\n- Talk about how to incorporate more movement into your daily lives',
    'preparation': 'Wear comfortable, stretchy clothing. Avoid eating a heavy meal beforehand. This date can be adapted by following a gentle online yoga video at home, or by choosing a different mindful movement practice like tai chi if yoga doesn\'t appeal.'
    },
    'Meditation Retreat': {
    'introduction': 'Find inner peace and deeper connection with a meditation retreat for two! This mindful date offers a respite from daily stress and an opportunity to develop presence with each other.',
    'steps': '1. Find a meditation center offering day retreats or drop-in sessions\n2. Begin with guided meditation if you\'re beginners\n3. Practice sitting in comfortable silence together\n4. Join a walking meditation if available\n5. Participate in mindfulness exercises as a pair\n6. Reflect on your experience over tea afterward',
    'touches': '- Bring comfortable cushions or meditation benches if you have them\n- Create a special quiet signal to check in with each other\n- Prepare a small gratitude journal to share thoughts after practice\n- Find a meaningful quote about presence to discuss',
    'conversation': '- Share how meditation affects your thoughts and feelings\n- Discuss challenges you experienced during the practice\n- Talk about how mindfulness might benefit your relationship',
    'preparation': 'Wear loose, comfortable clothing in layers. Avoid caffeine beforehand. This date can be adapted by creating a DIY meditation space at home with candles and soft music, or by trying a meditation app together if attending a retreat isn\'t possible.'
    },
    'Nature Walk and Picnic': {
    'introduction': 'Reconnect with nature and each other on a peaceful nature walk followed by a scenic picnic! This refreshing date combines gentle exercise with the pleasure of dining outdoors.',
    'steps': '1. Choose a nature trail with moderate difficulty and good views\n2. Pack a backpack with picnic essentials and water\n3. Walk at a leisurely pace, noticing plants and wildlife\n4. Find a beautiful spot with shade for your picnic\n5. Lay out a blanket and enjoy your meal together\n6. Take time to simply sit and absorb the natural surroundings',
    'touches': '- Bring a field guide to identify birds or plants\n- Pack a small magnifying glass for examining interesting finds\n- Include a special dessert to share at the end of your meal\n- Collect a small natural souvenir like a pretty leaf or stone',
    'conversation': '- Share childhood memories of time spent in nature\n- Discuss how different natural environments make you feel\n- Talk about environmental issues you both care about',
    'preparation': 'Check weather and trail conditions before heading out. Wear appropriate footwear and sun protection. This date can be adapted by choosing a wheelchair-accessible nature trail if needed, or by visiting a botanical garden if wild nature isn\'t accessible.'
    },
    'Couples Massage Experience': {
    'introduction': 'Indulge in the ultimate relaxation with a couples massage experience! This luxurious date allows you both to unwind side by side while skilled therapists melt away tension.',
    'steps': '1. Research spas with good reviews for couples massages\n2. Book in advance, specifying any preferences or concerns\n3. Arrive early to enjoy pre-massage amenities\n4. Communicate with your therapist about pressure preferences\n5. Focus on your breathing and releasing tension\n6. Take time to relax together in a quiet space afterward',
    'touches': '- Select a massage oil scent that you both enjoy\n- Bring comfortable clothes to change into afterward\n- Prepare a relaxing playlist for the drive home\n- Plan for a quiet, restful evening following your massage',
    'conversation': '- Share which areas of tension you noticed in your body\n- Discuss how stress manifests physically for each of you\n- Talk about other relaxation techniques you \'d like to try',
    'preparation': 'Drink plenty of water before and after. Avoid alcohol and heavy meals beforehand. This date can be adapted by learning basic massage techniques to practice on each other at home, or by visiting a reflexology spa that focuses just on feet if full-body massage isn\'t comfortable.'
    },
    'Relaxing Music Concert': {
    'introduction': 'Let beautiful melodies wash over you at a relaxing music concert! This soothing date surrounds you with live music in an atmosphere designed for appreciation and calm.',
    'steps': '1. Look for classical, jazz, acoustic, or ambient music performances\n2. Purchase tickets in advance for good seating\n3. Arrive early to read about the performers and program\n4. Close your eyes occasionally to fully immerse in the sound\n5. Notice how different pieces affect your emotions\n6. Discuss your experience over a quiet drink afterward',
    'touches': '- Dress up slightly to make the evening feel special\n- Bring opera glasses if in a large venue\n- Purchase a recording of music by the same artist to enjoy at home\n- Press a flower or save your ticket stub in a program as a memento',
    'conversation': '- Share which pieces resonated with you most and why\n- Discuss how music has been part of your lives\n- Talk about how different types of music affect your mood',
    'preparation': 'Familiarize yourself with concert etiquette if attending classical music. Turn phones off completely during the performance. This date can be adapted by finding a free outdoor concert if budget is a concern, or by creating a listening session at home with high-quality recordings and good speakers.'
    },
    'Pottery Class Therapy': {
    'introduction': 'Experience the therapeutic joy of working with clay in a pottery class designed for beginners! This hands-on date offers creative expression and the satisfaction of making something together.',
    'steps': '1. Find a pottery studio offering single-session classes\n2. Wear clothes that can get dirty and bring a towel\n3. Listen carefully to instructions on centering clay\n4. Start with simple forms like bowls or mugs\n5. Help each other troubleshoot challenges\n6. Make arrangements to pick up your fired pieces later',
    'touches': '- Take photos of your hands working the clay together\n- Create something that complements each other\'s work\n- Write your initials and the date on the bottom of your pieces\n- Bring hand cream for after class as clay can dry skin',
    'conversation': '- Discuss how it feels to create something from raw materials\n- Share what you find therapeutic about the process\n- Talk about where you\'ll display or how you\'ll use your creations',
    'preparation': 'Remove rings and watches before class. Trim fingernails short for easier clay work. This date can be adapted by trying air-dry clay at home if studio classes aren\'t available, or by choosing a different craft workshop if pottery doesn\'t appeal.'
    },
    'Mystery Date Adventure': {
    'introduction': 'Add excitement and surprise to your relationship with a mystery date where one partner plans everything in secret! This adventurous date builds anticipation and shows thoughtfulness in planning.',
    'steps': '1. Decide who will plan the first mystery date\n2. Provide basic information like dress code and duration\n3. Include a mix of activities your partner enjoys\n4. Add small surprise elements throughout the date\n5. Take photos to document the adventure\n6. Reveal the planning process at the end of the date',
    'touches': '- Create a themed invitation or clue to build anticipation\n- Include a small gift related to the activities\n- Prepare a playlist that hints at the destination\n- Take a "before and after" photo set',
    'conversation': '- Discuss which elements of surprise were most enjoyable\n- Share how it felt to either plan or receive the mystery date\n- Talk about other surprise experiences you\'d enjoy',
    'preparation': 'Consider any practical needs like comfortable shoes or weather-appropriate clothing. Be flexible if things don\'t go exactly as planned. This date can be adapted by creating a simpler mystery with fewer activities if time or budget is limited, or by giving more hints if complete surprises cause anxiety.'
    },
    'Food Tour Experience': {
    'introduction': 'Embark on a culinary adventure with a food tour that explores different flavors, cuisines, and local specialties! This delicious date combines eating with learning about food culture and history.',
    'steps': '1. Research guided food tours or create your own route of eateries\n2. Start with lighter dishes before moving to heartier options\n3. Share plates to try more varieties\n4. Take photos of particularly beautiful or interesting dishes\n5. Ask questions about ingredients and preparation methods\n6. Note your mutual favorites for future reference',
    'touches': '- Bring a small notebook to record favorite dishes\n- Create a rating system together for the different stops\n- Purchase a local spice or ingredient to use at home\n- Try at least one dish neither of you has had before',
    'conversation': '- Discuss your culinary backgrounds and family food traditions\n- Share your most memorable meals or food experiences\n- Talk about cuisines you\'d like to explore more deeply',
    'preparation': 'Eat a very light meal or skip the meal before the tour. Wear comfortable walking shoes and stretchy clothes. This date can be adapted by creating a DIY food tour in your own neighborhood, or by focusing on a specific type of food like desserts or street food if a full tour is too much.'
    },
    'Amusement Park Day': {
    'introduction': 'Recapture the joy and excitement of childhood with a day at an amusement park! This playful date combines thrilling rides, games, treats, and the perfect opportunity to let loose together.',
    'steps': '1. Check the park website for deals, hours, and ride closures\n2. Arrive early to beat crowds on popular attractions\n3. Start with a moderate ride to build excitement\n4. Take turns choosing the next attraction\n5. Try classic carnival games and food\n6. End with a spectacular ride or show',
    'touches': '- Wear matching accessories like hats or bandanas\n- Create a "must-ride" list and check items off\n- Take silly photos at photo booths or with park characters\n- Buy a small souvenir to remember the day',
    'conversation': '- Share memories of childhood visits to amusement parks\n- Discuss how you each handle thrills and excitement\n- Talk about which rides reveal something about your personalities',
    'preparation': 'Wear comfortable shoes and weather-appropriate clothing. Bring sunscreen and a water bottle. This date can be adapted by choosing a smaller carnival if a full amusement park is overwhelming, or by focusing on gentler rides and games if thrill rides aren\'t appealing.'
    },
    'Comedy Show Night': {
    'introduction': 'Share laughter and lighthearted fun at a comedy show! This entertaining date offers the chance to relax, enjoy live performance, and experience the contagious energy of collective humor.',
    'steps': '1. Research comedy clubs or venues with good reviews\n2. Check the performer\'s style to ensure it matches your humor\n3. Book tickets in advance for better seating\n4. Arrive early for good seats if it\'s open seating\n5. Be open to audience interaction if it happens\n6. Discuss your favorite jokes and moments afterward',
    'touches': '- Dress comfortably but slightly nicer than casual\n- Have a pre-show drink to relax and set the mood\n- Follow the comedian on social media as a memento\n- Look up the comedian\'s other work to enjoy later',
    'conversation': '- Discuss what types of humor you each enjoy most\n- Share comedians or funny shows you\'ve enjoyed in the past\n- Talk about how humor plays a role in your relationship',
    'preparation': 'Eat before the show unless dinner is included. Be prepared for audience interaction. This date can be adapted by watching a comedy special at home if live shows aren\'t available, or by attending an improv show for a different comedy experience.'
    },
    'Karaoke Evening': {
    'introduction': 'Let loose and embrace your inner rock star with a fun karaoke evening! This entertaining date encourages playfulness, mutual support, and creating memories through music and performance.',
    'steps': '1. Find a karaoke venue with private rooms or a welcoming public setting\n2. Start with a drink to relax inhibitions if desired\n3. Begin with a duet to break the ice\n4. Take turns choosing songs you each enjoy\n5. Cheer enthusiastically for each other\'s performances\n6. Record a short clip of your best duet as a memento',
    'touches': '- Create a list of potential songs beforehand\n- Dress in a slightly themed way for fun photos\n- Bring throat lozenges or tea for vocal care\n- Award each other silly superlatives at the end of the night',
    'conversation': '- Share stories about songs that have special meaning to you\n- Discuss musical influences and favorite artists growing up\n- Talk about concerts or performances you\'d like to see together',
    'preparation': 'Practice a few songs if you\'re nervous. Choose a mix of upbeat and slower songs to rest your voice. This date can be adapted by using a karaoke app at home if public singing feels too intimidating, or by attending a live music venue with sing-along opportunities if traditional karaoke isn\'t appealing.'
    },
    'Cozy Movie Marathon': {
    'introduction': 'Snuggle up for a cozy movie marathon tailored to your mutual interests! This relaxed date combines the comfort of home with the joy of shared stories and cinematic experiences.',
    'steps': '1. Select a theme or series of movies you both want to watch\n2. Prepare comfortable seating with plenty of pillows and blankets\n3. Arrange easy-to-eat snacks and drinks within reach\n4. Turn phones off or to silent mode\n5. Take short breaks between films to discuss and stretch\n6. Keep a list of movies you want to watch in the future',
    'touches': '- Create themed snacks that match the movies\n- Build a pillow fort or rearrange furniture for maximum coziness\n- Prepare movie trivia to share during breaks\n- Make physical tickets for each movie to make it feel special',
    'conversation': '- Discuss your reactions to plot twists and character developments\n- Share how different scenes or stories resonated with you\n- Talk about how movies have influenced your perspectives',
    'preparation': 'Test your viewing setup beforehand. Have backup movie options in case your first choice doesn\'t appeal. This date can be adapted by choosing shorter episodes of a TV series if full movies feel too long, or by attending a film festival or movie theater if you prefer to get out of the house.'
    },
    'Scenic Drive Adventure': {
    'introduction': 'Hit the open road for a scenic drive through beautiful landscapes! This relaxing date combines the freedom of the journey with the joy of discovering new vistas and hidden gems together.',
    'steps': '1. Research scenic routes within comfortable driving distance\n2. Create a loose itinerary with potential stops\n3. Prepare a travel playlist or interesting podcast\n4. Pack snacks, drinks, and a picnic if desired\n5. Stop at viewpoints and interesting attractions\n6. Take a different route home if possible',
    'touches': '- Bring a physical map to mark your route and discoveries\n- Pack a polaroid or instant camera for immediate souvenirs\n- Prepare a thermos of coffee or hot chocolate\n- Create a small "road trip kit" with treats and surprises',
    'conversation': '- Share memories of favorite trips or drives from your past\n- Discuss what you find most beautiful about the landscapes\n- Talk about dream road trips you\'d like to take together',
    'preparation': 'Check your vehicle before departing. Download offline maps in case of poor signal. This date can be adapted by taking public transportation to a scenic area if driving isn\'t an option, or by making it a shorter journey to a single beautiful destination if time is limited.'
    },
    'Relaxing Picnic Date': {
    'introduction': 'Escape the everyday with a relaxing picnic in a beautiful setting! This classic date combines delicious food with fresh air and the simple pleasure of dining together outdoors.',
    'steps': '1. Choose a scenic location with comfortable seating options\n2. Pack a variety of easy-to-eat foods and drinks\n3. Bring a comfortable blanket and optional pillows\n4. Set up your picnic with an eye for presentation\n5. Take your time enjoying each item and the surroundings\n6. Include time after eating to relax, talk, or play a simple game',
    'touches': '- Use real plates and cloth napkins for an elevated experience\n- Bring a small vase with a flower or two\n- Include a special dessert to share at the end\n- Pack a small bluetooth speaker for gentle background music',
    'conversation': '- Share childhood memories of outdoor meals or picnics\n- Discuss your favorite comfort foods and why they appeal to you\n- Talk about other outdoor activities you enjoy together',
    'preparation': 'Check weather forecasts carefully. Bring sunscreen, bug spray, and a backup plan in case of sudden weather changes. This date can be adapted by having an indoor picnic on the living room floor if weather is poor, or by visiting a prepared picnic area with tables if sitting on the ground isn\'t comfortable.'
    },
    'Book Reading Together': {
    'introduction': 'Share the intimate experience of reading aloud to each other in a comfortable setting! This thoughtful date creates connection through stories and gives you insight into each other\'s literary tastes.',
    'steps': '1. Select readings you\'d like to share with each other\n2. Create a comfortable reading nook with good lighting\n3. Prepare warm drinks and light snacks\n4. Take turns reading passages aloud for 15-20 minutes each\n5. Pause between readings to discuss your reactions\n6. Note books or authors you\'d like to explore further',
    'touches': '- Use bookmarks with special quotes or messages\n- Light candles or use soft lighting for atmosphere\n- Record a short clip of your reading as a memento\n- Exchange books as gifts at the end of the evening',
    'conversation': '- Discuss how the readings made you feel and what they made you think about\n- Share how books and stories have shaped your perspectives\n- Talk about favorite childhood books or formative reading experiences',
    'preparation': 'Choose readings of appropriate length - poetry, short stories, or book excerpts work well. Practice reading your selection beforehand if you\'re nervous. This date can be adapted by listening to an audiobook together if reading aloud feels uncomfortable, or by reading the same book separately and discussing it if you prefer.'
    },
    'Stargazing Evening': {
    'introduction': 'Gaze up at the vast night sky and discover celestial wonders together! This romantic date connects you with the cosmos and creates space for both awe and intimate conversation.',
    'steps': '1. Check moonphase and weather for optimal viewing conditions\n2. Find a location away from city lights with open sky views\n3. Bring comfortable seating or a blanket to lie on\n4. Download a stargazing app to identify constellations\n5. Take time to let your eyes adjust to the darkness\n6. Point out discoveries to each other as you find them',
    'touches': '- Bring a thermos of warm drinks to share\n- Pack red-light flashlights to preserve night vision\n- Prepare a playlist of space-themed or ambient music\n- Bring binoculars for enhanced viewing',
    'conversation': '- Share your thoughts about the vastness of the universe\n- Discuss space-related dreams or interests from childhood\n- Talk about how looking at the stars makes you feel',
    'preparation': 'Dress warmly with extra layers as temperatures drop at night. Check for astronomical events like meteor showers. This date can be adapted by using a stargazing app indoors if weather is poor, or by visiting a planetarium for a guided experience of the night sky.'
    },
    'New Restaurant Discovery': {
    'introduction': 'Embark on a culinary adventure by trying a new restaurant together! This flavorful date combines the excitement of discovery with the pleasure of sharing a meal in a fresh environment.',
    'steps': '1. Research recently opened or highly rated restaurants\n2. Make reservations if possible, especially for weekend dining\n3. Study the menu beforehand or go in with an open mind\n4. Order different dishes to share and sample\n5. Pay attention to the ambiance and presentation\n6. Discuss your experience and whether you\'d return',
    'touches': '- Dress up slightly to make the evening feel special\n- Take photos of particularly beautiful or interesting dishes\n- Ask the server for their recommendations\n- Save the receipt or menu as a souvenir',
    'conversation': '- Share your first impressions of the space and atmosphere\n- Discuss the flavor profiles and what you enjoy about each dish\n- Talk about other cuisines or restaurants you\'d like to try',
    'preparation': 'Check the restaurant\'s dress code if unsure. Consider dietary restrictions when selecting the restaurant. This date can be adapted by ordering takeout from a new restaurant to enjoy at home if dining out isn\'t possible, or by trying a new food truck or casual eatery if a full restaurant experience is too formal or expensive.'
    },
    'Museum Exploration': {
    'introduction': 'Wander through fascinating exhibits and expand your horizons with a museum date! This enriching experience offers cultural immersion, interesting conversation starters, and a glimpse into each other\'s curiosities.',
    'steps': '1. Research museums with exhibitions that might interest you both\n2. Check for special events, guided tours, or interactive exhibits\n3. Start with the exhibits that most interest you both\n4. Take your time, reading placards and discussing observations\n5. Visit the museum café or restaurant for a refreshment break\n6. Browse the gift shop for a small memento of your visit',
    'touches': '- Pick up a museum map and mark exhibits you especially enjoyed\n- Take photos of each other with favorite artworks or displays\n- Create a small scavenger hunt of things to find in the museum\n- Share interesting facts you learned with each other',
    'conversation': '- Discuss which exhibits resonated with you most and why\n- Share how different art styles or historical periods interest you\n- Talk about how museums featured in your education or upbringing',
    'preparation': 'Check museum policies on photography and bags. Wear comfortable shoes as museum visits involve lots of standing and walking. This date can be adapted by visiting a virtual museum online, or by focusing on a specific exhibition section if time or energy is limited.'
    },
    'Cooking Class Together': {
    'introduction': 'Roll up your sleeves and create a delicious meal together in a cooking class! This hands-on date combines learning new skills with the pleasure of enjoying the fruits of your labor.',
    'steps': '1. Find a cooking class featuring cuisine you both want to learn\n2. Register in advance as popular classes fill quickly\n3. Arrive hungry but not starving\n4. Take turns with different cooking tasks\n5. Ask questions and take notes for recreating dishes later\n6. Savor the meal you\'ve prepared together',
    'touches': '- Bring a small notebook to write down tips and recipe variations\n- Take photos of each cooking stage to remember the process\n- Purchase a special ingredient or tool used in class to use at home\n- Wear matching aprons if you have them',
    'conversation': '- Share family cooking traditions and favorite meals growing up\n- Discuss your kitchen dynamics and how you collaborate\n- Talk about other cuisines you\'d like to learn together',
    'preparation': 'Check if you need to bring anything specific. Wear comfortable shoes as cooking classes often involve standing for extended periods. This date can be adapted by finding a virtual cooking class to do at home, or by choosing a demonstration class with less hands-on work if you prefer.'
    },
    'Nature Walk Adventure': {
    'introduction': 'Immerse yourselves in the beauty and tranquility of nature with a refreshing walk through natural surroundings! This rejuvenating date connects you with the outdoors while providing quality time together.',
    'steps': '1. Research nature trails or parks with scenic paths\n2. Check weather and trail conditions before heading out\n3. Wear appropriate footwear and weather-suitable clothing\n4. Pack water and light snacks in a small backpack\n5. Walk at a comfortable pace, stopping to observe interesting sights\n6. Find a pleasant spot to rest and reflect together',
    'touches': '- Bring a field guide to identify plants or birds\n- Take close-up photos of interesting natural details\n- Collect a small natural souvenir like a pretty leaf or stone\n- Prepare a special trail mix with both your favorite ingredients',
    'conversation': '- Share observations about the natural environment around you\n- Discuss how spending time in nature affects your mood\n- Talk about favorite outdoor experiences from your past',
    'preparation': 'Apply sunscreen and insect repellent if needed. Check if the area requires any permits or has specific regulations. This date can be adapted by choosing a paved, accessible trail if mobility is a concern, or by visiting a botanical garden or arboretum if wild nature isn\'t accessible.'
    },
    'Local Event Attendance': {
    'introduction': 'Dive into your community\'s culture by attending a local event together! This engaging date connects you with your area\'s unique character while providing a shared experience to discuss and enjoy.',
    'steps': '1. Research upcoming events like festivals, fairs, or performances\n2. Choose something that interests you both or try something entirely new\n3. Purchase tickets in advance if required\n4. Arrive with time to explore the full event\n5. Participate in activities or demonstrations if available\n6. Discuss your experience over a drink or meal afterward',
    'touches': '- Check if there\'s event merchandise or program to keep as a souvenir\n- Take photos together at interesting spots within the event\n- Try local food or specialties available at the event\n- Introduce yourselves to organizers or artists if appropriate',
    'conversation': '- Share your impressions of different aspects of the event\n- Discuss similar events you\'ve enjoyed in the past\n- Talk about other local activities or traditions you\'d like to experience',
    'preparation': 'Check event websites for parking information and any items to bring or avoid. Bring cash for vendors who may not accept cards. This date can be adapted by choosing a smaller, less crowded event if large gatherings are overwhelming, or by finding a virtual community event if in-person attendance isn\'t possible.'
    },
    'Dessert Tasting Tour': {
    'introduction': 'Indulge your sweet tooth with a self-guided tour of the best dessert spots in town! This delightful date combines the pleasure of sweet treats with the fun of exploring different venues.',
    'steps': '1. Research bakeries, ice cream shops, and dessert cafés with good reviews\n2. Plan a route that lets you walk between locations if possible\n3. Start with lighter desserts before moving to richer options\n4. Share each item to try more varieties\n5. Rate each dessert on taste, presentation, and atmosphere\n6. Purchase your mutual favorite to enjoy later at home',
    'touches': '- Create a scoring card for rating each dessert\n- Take photos of particularly beautiful or unusual treats\n- Ask for recommendations from staff at each location\n- Bring small containers in case you want to take leftovers home',
    'conversation': '- Share childhood memories of favorite desserts\n- Discuss your preferences for different types of sweets\n- Talk about desserts from different cultures you\'d like to try',
    'preparation': 'Eat a light meal beforehand so you\'re not too full. Bring water to cleanse your palate between tastings. This date can be adapted by focusing on just one type of dessert like chocolate or ice cream if a full tour is too much, or by purchasing desserts to bring home for a tasting if sitting in cafés isn\'t preferred.'
    },
    'Rooftop Bar Sunset': {
    'introduction': 'Toast to your relationship against the backdrop of a stunning sunset at a rooftop bar! This romantic date combines sophisticated drinks, beautiful views, and the magic of dusk turning to evening.',
    'steps': '1. Research rooftop bars with good sunset views and atmosphere\n2. Arrive at least 30 minutes before sunset to secure good seating\n3. Order a special drink or share a bottle of wine\n4. Take photos as the light changes across the cityscape\n5. Stay after sunset to see the city lights come alive\n6. Discuss your favorite moments of the experience',
    'touches': '- Dress up slightly to match the elevated atmosphere\n- Learn a special toast in another language\n- Ask the bartender for a signature drink recommendation\n- Bring a light scarf or jacket as rooftops can get breezy',
    'conversation': '- Share your favorite time of day and why it appeals to you\n- Discuss how the cityscape looks different from above\n- Talk about other scenic viewpoints you\'d like to visit together',
    'preparation': 'Check if reservations are recommended or required. Verify the dress code if unsure. This date can be adapted by finding a ground-level bar or restaurant with sunset views if heights are uncomfortable, or by creating a sunset picnic in a scenic spot if bar settings aren\'t preferred.'
    },
    'Arcade Game Challenge': {
    'introduction': 'Embrace your playful competitive spirit with a fun-filled arcade game challenge! This entertaining date combines nostalgic games, friendly competition, and the simple joy of playing together.',
    'steps': '1. Find an arcade with a good mix of classic and modern games\n2. Purchase a game card or tokens to share\n3. Start with cooperative games before moving to competitive ones\n4. Challenge each other to beat high scores\n5. Save tickets for a silly prize at the end\n6. Take victory selfies with your favorite games',
    'touches': '- Create a mini tournament with specific games and keep score\n- Winner gets to choose the next activity or restaurant\n- Take photo booth pictures as a memento\n- Exchange small arcade prizes as "trophies"',
    'conversation': '- Share memories of favorite games from childhood\n- Discuss how you each handle winning and losing\n- Talk about how games and play remain important in adulthood',
    'preparation': 'Bring hand sanitizer as arcade games can be germy. Set a budget for games beforehand. This date can be adapted by finding a board game café if arcades are too noisy, or by creating a game night at home with video or board games if going out isn\'t preferred.'
    },
    'Bowling Night Fun': {
    'introduction': 'Strike up fun and friendly competition with a classic bowling date! This nostalgic activity combines physical skill, playful rivalry, and plenty of opportunities for celebration and laughter.',
    'steps': '1. Find a bowling alley with good reviews and atmosphere\n2. Reserve a lane in advance for popular times\n3. Choose fun bowling names for the scoreboard\n4. Take turns coaching each other on technique\n5. Celebrate strikes and spares enthusiastically\n6. Enjoy snacks or drinks between frames',
    'touches': '- Create silly bowling victory dances\n- Take scoreboard photos to remember your game\n- Make a small wager like winner chooses dessert\n- Bring lucky socks or other playful accessories',
    'conversation': '- Share previous bowling experiences or memories\n- Discuss other classic activities you enjoyed growing up\n- Talk about how friendly competition plays a role in your relationship',
    'preparation': 'Wear or bring socks for rental shoes. Consider booking during off-peak hours for a more relaxed experience. This date can be adapted by trying duckpin bowling which uses smaller balls if traditional bowling is too strenuous, or by finding a bowling video game to play at home if going out isn \'t preferred.'
    },
    'Mini Golf Adventure': {
    'introduction': 'Putt your way through whimsical obstacles and friendly competition with a mini golf date! This playful activity offers lighthearted fun, gentle physical activity, and plenty of opportunities for laughter.',
    'steps': '1. Find a mini golf course with creative theming or good reviews\n2. Choose colorful golf balls that reflect your personalities\n3. Take silly poses before teeing off at each hole\n4. Offer gentle tips without overcorrecting each other\n5. Keep score loosely, focusing on fun over competition\n6. Celebrate with a treat from the snack bar afterward',
    'touches': '- Take photos at the most creative or challenging holes\n- Create a special handshake for when either of you gets a hole-in-one\n- Winner gets to keep both golf balls as a trophy\n- Make up backstories for the course obstacles',
    'conversation': '- Share memories of childhood games and competitions\n- Discuss your approaches to learning new skills\n- Talk about other playful activities you\'d enjoy trying together',
    'preparation': 'Wear comfortable shoes and weather-appropriate clothing. Apply sunscreen if the course is outdoors. This date can be adapted by finding an indoor course if weather is poor, or by creating a DIY mini golf course at home with household items if going out isn\'t preferred.'
    },
    'Picnic in the Park': {
    'introduction': 'Enjoy the simple pleasure of dining outdoors with a relaxing picnic in a beautiful park! This classic date combines fresh air, delicious food, and the joy of creating your own dining experience in nature.',
    'steps': '1. Choose a park with nice scenery and comfortable seating areas\n2. Pack a variety of finger foods, drinks, and dessert\n3. Bring a comfortable blanket and optional pillows\n4. Set up your picnic with an eye for presentation\n5. Take your time enjoying each item and the surroundings\n6. Include a simple activity like frisbee or cards after eating',
    'touches': '- Bring a small portable speaker for background music\n- Pack a small vase with fresh flowers for the center\n- Include a special homemade item that shows effort\n- Bring a polaroid camera for instant memories',
    'conversation': '- Share favorite outdoor memories from different seasons\n- Discuss the simple pleasures that bring you joy\n- Talk about dream picnic locations around the world',
    'preparation': 'Check weather forecasts carefully. Bring sunscreen, bug spray, and a backup plan in case of sudden weather changes. This date can be adapted by having an indoor picnic on the living room floor if weather is poor, or by choosing a park with covered pavilions if you want protection from sun or light rain.'
    },
    'Drive-in Movie Night': {
    'introduction': 'Experience the nostalgic charm of watching a movie under the stars at a drive-in theater! This retro date combines the comfort of your own car with the unique atmosphere of outdoor cinema.',
    'steps': '1. Check the drive-in schedule and choose a movie you both want to see\n2. Arrive early to get a good parking spot with clear view\n3. Set up your car with comfortable pillows and blankets\n4. Bring your own snacks and drinks for a personalized experience\n5. Tune your radio to the correct station for audio\n6. Stay for both movies if it\'s a double feature',
    'touches': '- Create a "car picnic" with special movie snacks\n- Bring battery-powered string lights for ambiance\n- Make movie-themed treats related to the film\n- Pack extra blankets for cooler evening temperatures',
    'conversation': '- Share memories of favorite movie-watching experiences\n- Discuss your thoughts about the film during intermission\n- Talk about other classic experiences you\'d like to revive',
    'preparation': 'Check if the drive-in has any rules about outside food or car height. Make sure your car battery is strong or bring a portable radio. This date can be adapted by creating a backyard movie night with a projector if drive-ins aren\'t available, or by finding a dine-in movie theater for a similar but indoor experience.'
    },
    'Sunrise Coffee Date': {
    'introduction': 'Begin your day together watching the world wake up with a peaceful sunrise coffee date! This early morning experience offers tranquility, beautiful colors, and the special feeling of sharing a moment most people miss.',
    'steps': '1. Check sunrise time and choose a good viewing location\n2. Prepare a thermos of coffee or tea the night before\n3. Pack light breakfast items like pastries or fruit\n4. Arrive at least 15 minutes before sunrise\n5. Find a comfortable spot with an eastern view\n6. Stay to enjoy how the landscape changes as light increases',
    'touches': '- Bring warm mugs and a cozy blanket to share\n- Include a small breakfast surprise like homemade muffins\n- Take a "before and after" photo set of the landscape\n- Write down a wish or intention for the day together',
    'conversation': '- Share how mornings feature in your daily routines\n- Discuss how the peaceful early hours make you feel\n- Talk about other natural phenomena you\'d like to experience together',
    'preparation': 'Set multiple alarms to ensure you wake up on time. Prepare as much as possible the night before. This date can be adapted by watching sunrise from a balcony or window if traveling to a location isn\'t feasible, or by choosing a sunset date instead if early mornings are too challenging.'
    },
    'Volunteer Together': {
    'introduction': 'Make a difference while connecting with each other by volunteering for a cause you both care about! This meaningful date allows you to give back to your community while seeing new sides of each other.',
    'steps': '1. Discuss causes that matter to both of you\n2. Research volunteer opportunities that don\'t require long-term commitment\n3. Register in advance as many organizations require it\n4. Arrive on time and with a positive attitude\n5. Work together as a team when possible\n6. Reflect on your experience over a meal afterward',
    'touches': '- Take a photo of your volunteer badges or location\n- Wear matching colors or items to show you\'re a team\n- Bring treats to share with other volunteers\n- Exchange notes about what you observed about each other during the experience',
    'conversation': '- Share what drew you to this particular cause\n- Discuss how helping others makes you feel\n- Talk about other ways you\'d like to make a positive impact',
    'preparation': 'Dress appropriately for the activity. Check if the organization requires any specific items or preparation. This date can be adapted by finding a virtual volunteer opportunity if in-person options aren\'t available, or by doing a smaller act of service like neighborhood cleanup if formal volunteering isn\'t possible.'
    },
    'Bookstore Exploration': {
    'introduction': 'Discover new worlds and insights while browsing the shelves of a bookstore together! This thoughtful date reveals your interests and tastes while surrounding you with the peaceful atmosphere of books and ideas.',
    'steps': '1. Find an independent bookstore with character and good selection\n2. Start by exploring separately to discover your own interests\n3. Choose one book you think your partner would enjoy\n4. Meet at the café section if available to share your finds\n5. Read interesting passages to each other\n6. Consider purchasing a book to read together',
    'touches': '- Leave small notes in books you want your partner to find\n- Take a "what we\'re reading" photo together\n- Create a list of books you both want to read\n- Find a book that relates to your relationship or shared interests',
    'conversation': '- Discuss genres and topics that captivate you\n- Share how books have influenced your thinking\n- Talk about favorite childhood books or reading memories',
    'preparation': 'Check bookstore hours and any café seating policies. Bring reading glasses if needed. This date can be adapted by focusing on a specific section of the bookstore if time is limited, or by visiting a library instead if you prefer not to purchase books.'
    },
    'Farmers Market Brunch': {
    'introduction': 'Combine the pleasure of fresh local food shopping with a delicious meal at a farmers market brunch date! This sensory-rich experience connects you with local producers while enjoying a morning together.',
    'steps': '1. Research which farmers markets have prepared food vendors\n2. Arrive early for the best selection and shorter lines\n3. Take a complete lap before deciding what to eat\n4. Purchase different items to share and sample\n5. Find a comfortable spot to enjoy your market meal\n6. Shop for fresh ingredients to cook together later',
    'touches': '- Bring your own reusable bags and containers\n- Purchase a small bouquet of fresh flowers\n- Sample something neither of you has tried before\n- Take photos of the most colorful produce displays',
    'conversation': '- Discuss your favorite seasonal foods and how you enjoy them\n- Share family recipes that use fresh ingredients\n- Talk about food sustainability and supporting local businesses',
    'preparation': 'Bring cash as some vendors may not accept cards. Check market hours as many close by early afternoon. This date can be adapted by visiting an indoor market in bad weather, or by creating a special brunch at home with previously purchased local ingredients if markets aren\'t available.'
    },
    'Botanical Garden Stroll': {
    'introduction': 'Wander among beautiful plants and flowers on a peaceful botanical garden stroll! This serene date surrounds you with natural beauty while providing a tranquil setting for meaningful conversation.',
    'steps': '1. Check the garden website for what\'s currently blooming\n2. Consider guided tour options or audio guides if available\n3. Pick up a map and plan your route through different sections\n4. Take your time in each area, noticing details and reading placards\n5. Find a quiet bench in your favorite section to sit and talk\n6. Visit the garden shop for a plant or seed packet to grow at home',
    'touches': '- Bring a plant identification app to learn more about favorites\n- Take close-up photos of interesting textures and patterns\n- Prepare a small sketchbook to draw particularly beautiful specimens\n- Research the language of flowers and share meanings of ones you see',
    'conversation': '- Discuss which environments and plants you\'re drawn to\n- Share memories of gardens or plants from your childhood\n- Talk about how different landscapes make you feel',
    'preparation': 'Check weather and dress accordingly. Wear comfortable walking shoes and bring water. This date can be adapted by using a wheelchair-accessible route if needed, or by focusing on indoor conservatories if weather is poor or energy is limited.'
    },
    'Aquarium Visit': {
    'introduction': 'Dive into an underwater world of wonder with a visit to an aquarium! This fascinating date surrounds you with colorful marine life while providing both education and entertainment.',
    'steps': '1. Check for special exhibits or feeding times before your visit\n2. Arrive early to avoid crowds, especially at popular exhibits\n3. Take your time at each tank, noticing details and behaviors\n4. Read information placards to learn interesting facts\n5. Attend a scheduled talk or feeding if available\n6. Find a favorite exhibit to revisit before leaving',
    'touches': '- Challenge each other to find the most unusual creature\n- Take photos of each other silhouetted against large tanks\n- Purchase a small marine-themed souvenir\n- Share interesting facts you learn with each other',
    'conversation': '- Discuss which marine environments most fascinate you\n- Share experiences with oceans, lakes, or rivers from your past\n- Talk about ocean conservation and environmental issues',
    'preparation': 'Check if photography is permitted and if flash is allowed. Wear layers as aquariums are often kept cool. This date can be adapted by watching a marine documentary together if aquariums aren\'t accessible, or by visiting a pet store with fish sections for a smaller-scale experience.'
    },
    'Bike Rental Adventure': {
    'introduction': 'Feel the breeze in your hair as you explore on a bike rental adventure! This active date combines gentle exercise with the freedom to discover new areas at your own pace.',
    'steps': '1. Find a bike rental location near interesting paths or sights\n2. Check bike fit and adjustments before setting off\n3. Plan a route with interesting stops and beautiful views\n4. Take breaks to hydrate and enjoy the surroundings\n5. Stop for a snack or meal at a scenic point\n6. Take photos at your favorite discoveries along the way',
    'touches': '- Bring a small backpack with water and snacks\n- Create a custom route map highlighting points of interest\n- Pack a small bluetooth speaker for music (if appropriate)\n- Prepare a surprise destination along the route',
    'conversation': '- Share memories of learning to ride a bike\n- Discuss how different forms of transportation change how we experience places\n- Talk about other areas you\'d like to explore together',
    'preparation': 'Check weather forecasts and dress appropriately. Bring sunscreen and water bottles. This date can be adapted by choosing electric bikes if fitness levels differ, or by finding a tandem bike if you want to ride together.'
    },
    'Dessert and Coffee Date': {
    'introduction': 'Indulge your sweet tooth and enjoy stimulating conversation with a dessert and coffee date! This classic pairing offers a perfect setting for connection without the commitment of a full meal.',
    'steps': '1. Find a café known for excellent desserts or coffee\n2. Choose different desserts to share and sample\n3. Order complementary coffee drinks that pair well\n4. Take your time savoring each bite and sip\n5. Discuss the flavors and which combinations work best\n6. Walk together afterward to enjoy the sweetness of conversation',
    'touches': '- Research the café\'s specialties beforehand\n- Take photos of particularly beautiful desserts\n- Learn about coffee origins or dessert history to share\n- Bring mints for after your sweet treats',
    'conversation': '- Share your dessert preferences and coffee rituals\n- Discuss favorite cafés you\'ve visited in other places\n- Talk about comfort foods and treats from childhood',
    'preparation': 'Check café hours and busy times to avoid crowds. Consider timing between meals when you\'re not too full. This date can be adapted by getting desserts to go and enjoying them in a park or at home, or by creating a dessert tasting at home with store-bought treats if going out isn\'t preferred.'
    },
      'Art Gallery Exploration': {
        'introduction': 'Immerse yourselves in creativity and culture with an art gallery exploration! This thoughtful date offers beautiful visuals, interesting conversations, and a glimpse into each other\'s aesthetic preferences.',
        'steps': '1. Research galleries featuring exhibitions that might interest you both\n2. Check for special events like opening nights or artist talks\n3. Start with smaller galleries before moving to larger museums\n4. Take your time in each room, focusing on pieces that catch your eye\n5. Share your impressions without worrying about art expertise\n6. Visit the gallery café or gift shop to extend the experience',
        'touches': '- Purchase a small art print or postcard as a memento\n- Take photos of each other with favorite artworks\n- Bring a small notebook to sketch or write impressions\n- Research one interesting fact about the featured artist beforehand',
        'conversation': '- Discuss which pieces resonate with you and why\n- Share how different art styles make you feel\n- Talk about art or creativity in your own lives and upbringing',
        'preparation': 'Check gallery policies on photography and bags. Wear comfortable shoes as gallery viewing involves lots of standing and walking. This date can be adapted by visiting a virtual gallery online, or by focusing on a specific exhibition section if time or energy is limited.'
      },
// Add more date ideas here
    };

// Get the content for this specific date idea, or use a random one if not found
    Map<String, String>? content = dateContent[ideaTitle];

    if (content == null) {
      final keys = dateContent.keys.toList();
      if (keys.isNotEmpty) {
        // Filter out previously used ideas if possible
        final availableKeys = keys.where((k) => !_usedRandomIdeas.contains(k)).toList();
        final randomKey = availableKeys.isNotEmpty
            ? availableKeys[Random().nextInt(availableKeys.length)]
            : keys[Random().nextInt(keys.length)];

        // Track this idea as used
        _usedRandomIdeas.add(randomKey);

        // Reset tracking if we've used too many
        if (_usedRandomIdeas.length > keys.length / 2) {
          _usedRandomIdeas.clear();
        }

        content = dateContent[randomKey]!;
        // Update the ideaTitle to match the randomly selected date
        ideaTitle = randomKey;
      } else {
        // Fallback content if somehow the map is empty
        content = {
          'introduction': 'Experience a wonderful date tailored to your preferences and moods.',
          'steps': 'Plan your perfect date with activities you both enjoy.',
          'touches': 'Add personal elements to make the date memorable and special.',
          'conversation': 'Discuss your experiences, preferences, and create meaningful connections.',
          'preparation': 'Prepare appropriately and be ready to adapt based on circumstances.'
        };
      }
    }

    return '''$ideaTitle

INTRODUCTION:
${content['introduction']}

STEP-BY-STEP GUIDE:
${content['steps']}

SPECIAL TOUCHES:
${content['touches']}

CONVERSATION STARTERS:
${content['conversation']}

PREPARATION & ADAPTATIONS:
${content['preparation']}

Suggested Places: $placeSuggestions''';
  }

  static List<String> getDateIdeas(String mood1, String mood2) {
    final key = _getCombinationKey(mood1, mood2);
    return _dateIdeas[key] ?? _dateIdeas['default']!;
  }


  static List<String> getFormattedDateIdeas(String mood1, String mood2) {
    final ideas = getDateIdeas(mood1, mood2);

    // Create a copy and shuffle to get random order
    final shuffledIdeas = List<String>.from(ideas)..shuffle();

    return shuffledIdeas.map((idea) {
      final categories = DateIdeaService.categorizeDateIdea(idea);
      return getFormattedDateIdea(idea, categories);
    }).toList();
  }


  static String _getCombinationKey(String mood1, String mood2) {
    // Convert mood names to lowercase for case-insensitive comparison
    String m1 = mood1.toLowerCase();
    String m2 = mood2.toLowerCase();

    if (m1 == 'stressed' || m2 == 'stressed') return 'stressed_any';
    if (m1 == 'excited' || m2 == 'excited') return 'excited_any';
    if (m1 == 'tired' || m2 == 'tired') return 'tired_any';

    if (m1 == 'energized' && m2 == 'energized') return 'energetic_energetic';
    if ((m1 == 'energized' && m2 == 'calm') || (m1 == 'calm' && m2 == 'energized')) return 'energetic_calm';
    if (m1 == 'calm' && m2 == 'calm') return 'calm_calm';

    return 'default';
  }


}
