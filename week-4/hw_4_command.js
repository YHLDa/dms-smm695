mongo

// Q1
use smm695
db

// Q2
db.hmw4.insertMany([
    {"name": "Traveling Wilburys",
    "birth": 1988,
    "members": "[Bob Dylan, George Horrison, Jeff Lynne, Roy Orbison, Tom Petty]",
    "break up": 1991
    },    
    {"name": "Temple of the Dog",
    "birth": 1990,
    "members": "[Chris Cornell, Jeff Ament, Matt Cameron, Stone Gossard, Mike McCready, Eddie Vedder]",
    "break up": 1992
    },
    {"name": "The White Stripes",
    "birth": 1997,
    "members": "[Jack White, Meg White]",
    "break up": 2011
    },
    {"name": "The Three Tenors",
    "birth": 1990,
    "members": "[Placido Domingo, Jose Carreras, Luciano Pavarotti]",
    "break up": 2007
    },
    {"name": "LSD",
    "birth": 2018,
    "members": "[Sia Furler, Timothy McKenzie, Wesly Pentz]"
    }
]);

// Q3
db.hmw4.updateMany(
    {"name": "Traveling Wilburys"},
    {$set: {"album": 4}}
);
db.hmw4.updateMany(
    {"name": "Temple of the Dog"},
    {$set: {"album": 1}}
);
db.hmw4.updateMany(
    {"name": "The Three Tenors"},
    {$set: {"album": 14}}
);
db.hmw4.updateMany(
    {"name": "LSD"},
    {$set: {"album": 1}}
);

// Q4
db.hmw4.updateOne(
    {"name": "Traveling Wilburys"},
    {$set: {"name": "The Traveling Wilburys"}}
);

// Q5
db.hmw4.deleteOne({"name": "The White Stripes"});

// Q6
