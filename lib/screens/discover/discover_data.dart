import 'discover_item.dart';

const List<DiscoverItem> discoverItems = [

  // ====================== HIGHWAYS (PAN-INDIA) ======================
  DiscoverItem(
    category: "Highway",
    title: "Delhi–Mumbai Expressway",
    subtitle: "India’s longest expressway (1,386 km)",
    description:
    "Access-controlled expressway between Delhi and Mumbai. Sections like Sohna–Dausa–Lalsot and stretches in MP & Gujarat are already operational. When fully complete, it will bring travel time down to ~12.5 hours.",
    status: "Partially Open",
    eta: "Full completion by Oct 2025",
    highlights: [
      "8-lane expandable to 12-lane",
      "Multiple wildlife overpasses and tunnels",
      "EV charging plazas and wayside amenities",
      "Signal-free corridor with smart monitoring"
    ],
    emoji: "🚗",
  ),

  DiscoverItem(
    category: "Highway",
    title: "Dwarka Expressway",
    subtitle: "India’s first elevated urban expressway",
    description:
    "Connects Delhi and Gurugram as an alternate to the congested NH-8. Both Delhi and Haryana sections have opened in 2024, decongesting a key NCR link.",
    status: "Operational",
    eta: "Opened in early 2024",
    highlights: [
      "19 km long elevated corridor",
      "Reduces load on NH-8 significantly",
      "Multiple interchanges and underpasses",
    ],
    emoji: "🛣️",
  ),

  DiscoverItem(
    category: "Highway",
    title: "Mumbai–Nagpur Expressway (Samruddhi Mahamarg)",
    subtitle: "701 km high-speed expressway",
    description:
    "Access-controlled corridor connecting Nagpur to near Igatpuri, linking 10 districts. Large sections are operational, cutting travel time between Mumbai and Nagpur to around 8 hours.",
    status: "Mostly Operational",
    eta: "Final stretches by 2025",
    highlights: [
      "Connects 10 major districts of Maharashtra",
      "Smart surveillance and safety infrastructure",
      "Enables industrial and logistics growth",
    ],
    emoji: "🚗",
  ),

  DiscoverItem(
    category: "Highway",
    title: "Delhi–Saharanpur–Dehradun Expressway",
    subtitle: "210 km corridor to the hills",
    description:
    "First 32 km stretch from Akshardham (Delhi) to Khekra (Baghpat) is open for trial runs. When fully operational, it will cut Delhi–Dehradun travel time to nearly 2.5 hours.",
    status: "Under Construction",
    eta: "Early 2026",
    highlights: [
      "Multiple bridges over Yamuna & tributaries",
      "Dedicated greenfield stretches",
      "Improved access to Uttarakhand tourism regions",
    ],
    emoji: "🛣️",
  ),

  DiscoverItem(
    category: "Highway",
    title: "Sudarshan Setu Bridge",
    subtitle: "Cable-stayed bridge to Beyt Dwarka",
    description:
    "2.32 km bridge connecting Okha mainland with Beyt Dwarka island in Gujarat. Inaugurated in Feb 2024 to provide an all-weather link and boost tourism.",
    status: "Operational",
    eta: "Opened Feb 2024",
    highlights: [
      "Cable-stayed sea bridge",
      "All-weather island connectivity",
      "Boosts religious and coastal tourism",
    ],
    emoji: "🌉",
  ),

  // ====================== KERALA HIGHWAYS ======================
  DiscoverItem(
    category: "Highway",
    title: "NH 66 Widening – Kerala Coastal Corridor",
    subtitle: "669 km Kasaragod–Thiruvananthapuram upgrade",
    description:
    "Massive six-lane upgrade of coastal NH 66 across Kerala with service roads. Sections like Thalappady–Chengala and Ramanattukara–Valanchery are already open or partially open.",
    status: "Under Construction",
    eta: "Dec 2025 / Early 2026",
    highlights: [
      "Six-lane, signal-free coastal highway",
      "Service roads for local traffic",
      "Reduced congestion in coastal towns",
    ],
    emoji: "🛣️",
  ),

  DiscoverItem(
    category: "Highway",
    title: "Kuthiran Tunnel (NH 544)",
    subtitle: "Twin-tube tunnel on Kochi–Thrissur stretch",
    description:
    "Six-lane twin-tube tunnel on the Wadakkanchery–Thrissur section. It eliminates a long-standing bottleneck on the Kochi–Thrissur–Palakkad–Walayar corridor.",
    status: "Operational",
    eta: "Fully open",
    highlights: [
      "Improves safety on ghat section",
      "Significantly reduces congestion",
      "Part of key freight corridor",
    ],
    emoji: "🚇",
  ),

  DiscoverItem(
    category: "Highway",
    title: "Thalassery–Mahe Bypass (NH 66)",
    subtitle: "18.6 km bypass to decongest coastal towns",
    description:
    "Bypass designed to reduce congestion around Thalassery and Mahe on NH 66. Under phased completion.",
    status: "Under Construction",
    eta: "By 2025",
    highlights: [
      "Smoother coastal movement",
      "Avoids town centre traffic",
      "Supports cross-border movement between Kerala & Puducherry (Mahe)",
    ],
    emoji: "🛣️",
  ),

  // ====================== FLIGHTS ======================
  DiscoverItem(
    category: "Flights",
    title: "Air Kerala – New State Airline",
    subtitle: "Intra-Kerala & South India connectivity",
    description:
    "Kerala-based airline targeting domestic operations from June 2025, with its first flights from Kannur. Focus on intra-Kerala and nearby South Indian cities.",
    status: "Upcoming",
    eta: "Launch planned June 2025",
    highlights: [
      "Kannur as initial hub",
      "Routes: Kochi, Thiruvananthapuram, Calicut",
      "Connectivity to Mysuru, Bengaluru, Chennai, Hyderabad",
    ],
    emoji: "✈️",
  ),

  DiscoverItem(
    category: "Flights",
    title: "Al Hind Air – Regional Airline",
    subtitle: "New Kochi-based carrier",
    description:
    "Launching in 2025 with ATR aircraft focused on regional domestic connectivity from Kochi.",
    status: "Upcoming",
    eta: "2025",
    highlights: [
      "Kochi → Madurai",
      "Kochi → Chennai",
      "Kochi → Bengaluru",
      "Kochi → Thiruvananthapuram",
    ],
    emoji: "✈️",
  ),

  DiscoverItem(
    category: "Flights",
    title: "IndiGo – New Domestic Routes",
    subtitle: "Tier-2 & Tier-3 connectivity",
    description:
    "IndiGo has added several routes for better regional connectivity across India.",
    status: "Operational",
    eta: "Early 2024 onwards",
    highlights: [
      "Ahmedabad → Rajkot",
      "Ahmedabad → Aurangabad",
      "Bhopal → Lucknow",
      "Indore → Varanasi",
      "Kolkata → Srinagar",
      "Kolkata → Jammu",
      "Extra Kochi–Thiruvananthapuram services",
    ],
    emoji: "🛫",
  ),

  DiscoverItem(
    category: "Flights",
    title: "Akasa Air – Kochi & Ayodhya Connectivity",
    subtitle: "New religious & business routes",
    description:
    "Akasa Air has launched daily operations on sectors like Kochi–Ahmedabad and Kochi–Navi Mumbai, alongside Ayodhya-linked connectivity via major metros.",
    status: "Operational",
    eta: "2024–2025",
    highlights: [
      "Kochi ↔ Ahmedabad",
      "Kochi ↔ Navi Mumbai",
      "Support to Ayodhya-bound traffic via metro hubs",
    ],
    emoji: "✈️",
  ),

  DiscoverItem(
    category: "Flights",
    title: "Ayodhya Pilgrimage Flights",
    subtitle: "Multi-airline religious corridor",
    description:
    "Post-development of Ayodhya as a major pilgrimage destination, multiple airlines added direct and connecting routes.",
    status: "Operational",
    eta: "2024–2025",
    highlights: [
      "Direct flights from Delhi, Mumbai, Bengaluru, Chennai, Ahmedabad",
      "Operated by IndiGo, SpiceJet, Akasa Air",
    ],
    emoji: "🛕",
  ),

  DiscoverItem(
    category: "Flights",
    title: "SpiceJet – New Regional Routes",
    subtitle: "Connectivity to emerging destinations",
    description:
    "SpiceJet has introduced routes connecting smaller cities to major metros, improving regional access.",
    status: "Operational",
    eta: "2025 onwards",
    highlights: [
      "Tuticorin → Chennai / Bengaluru / Mumbai (via sectors)",
      "Porbandar connected to major hubs",
      "Dehradun linked with metro networks",
    ],
    emoji: "🛩️",
  ),

  DiscoverItem(
    category: "Flights",
    title: "Star Air – Kochi ↔ Bengaluru",
    subtitle: "4x weekly regional connection",
    description:
    "Star Air has launched four weekly services on the Kochi–Bengaluru route, improving business and leisure connectivity.",
    status: "Operational",
    eta: "2024",
    highlights: [
      "ATR/Regional jet operations",
      "Convenient timings for business travellers",
    ],
    emoji: "🛫",
  ),

  // ====================== BUS NETWORKS ======================
  DiscoverItem(
    category: "Bus",
    title: "FlixBus – North India Network",
    subtitle: "46-city green intercity bus grid",
    description:
    "FlixBus entered India in Feb 2024 with Delhi as its primary hub, connecting dozens of North Indian cities.",
    status: "Operational",
    eta: "Feb 2024",
    highlights: [
      "Delhi as main hub",
      "Routes to Ayodhya, Jaipur, Manali, Dehradun, Varanasi and more",
      "App-based booking, dynamic pricing",
    ],
    emoji: "🚌",
  ),

  DiscoverItem(
    category: "Bus",
    title: "Zingbus PLUS Electric",
    subtitle: "Premium EV intercity buses",
    description:
    "Zingbus has launched 'Plus Electric' service starting with a premium EV route between Delhi and Dehradun.",
    status: "Operational",
    eta: "2024",
    highlights: [
      "Electric intercity coach",
      "Delhi → Dehradun pilot route",
      "Focus on comfort + low emissions",
    ],
    emoji: "🔋",
  ),

  DiscoverItem(
    category: "Bus",
    title: "KSRTC Kerala – 503 New Routes",
    subtitle: "Urban–rural last-mile transport plan",
    description:
    "Kerala’s Transport Department notified 503 new routes in Oct 2025 under the ‘Kerala Public Transport Urban-Rural Integration and Last-Mile Connectivity Scheme, 2025’.",
    status: "Upcoming",
    eta: "2025 rollout",
    highlights: [
      "Targets underserved rural & suburban pockets",
      "Includes AC sleeper and BS6 superfast services",
      "Sample routes: Josgiri–Iritty, Sreekrishnapuram–Ottapalam",
    ],
    emoji: "🚌",
  ),
];
