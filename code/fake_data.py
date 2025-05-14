import faker
from faker import Faker
import random
from datetime import datetime, timedelta, time

def sql_str(value): #escapes single quotes 
    return str(value).replace("'", "''")

#function to generate sql insert statment

def generate_sql(table_name, table_atributes,dict, dict_keys):
    s = f"INSERT INTO {table_name}\n ("
    for atr in table_atributes[:-1]:
        s += f"{sql_str(atr)}, "
    s += f"{sql_str(table_atributes[-1])})\nVALUES\n("
    for key in dict_keys[:-1]:
        s += f"'{sql_str(dict[key])}', "
    s += f"'{sql_str(dict[dict_keys[-1]])}')\n;\n"
    return s

Faker.seed(2)
fake = Faker()

loc_num, fest_num = 20,10
stage_num = 30
perf_num =100
ticket_num = 200
artist_num = 50
band_num = 10


def generate_locations(continents):  #takes as input continents dictionrary
    return {
        'address': fake.address().replace('\n', ','),
        'long': fake.longitude(),
        'lat': fake.latitude(),
        'city': fake.city(),
        'country': fake.country(),
        'continent_id': random.choice(continents)['id']   #selects id of random continent
    } 

def genarate_festivals(id,year):
    date = fake.unique.date_between(start_date='-7y', end_date='+2y')   #date or date_time is best??
    date = date.replace(year=int(year))
    return {
        'id': id,
        'name': fake.word() + 'Pulse University Festival',
        'start_date': date,
        'end_date': date + timedelta(days= random.choice(range(5))),  #ends in the same day or up to 4 days later
        'location_id': random.choice(range(1,loc_num+1))    #loc['id'] ranges from 1 to loc_num+1
    }

def genarate_stage():
    return{
        'name': fake.word() + 'Stage',
        'desc': fake.paragraph(),
        'max_cap': random.randint(500,2000),
        'tech_req': fake.paragraph()
    }


def generate_events(fest,stages):  #generate event for given festival dictionary, #assume differnet  festivals can use the same stage
    start_time = time(random.randint(12,16),00,00)     #start between 12 to 16 pm
    start_datetime = datetime.combine( fest['start_date'], start_time) #i will use it for performances           
    event_num = (fest['end_date'] - fest['start_date']).days + 1  #one event per day
    stage_samples = random.sample(list(enumerate(stages, start=1)), event_num)
    stages_id = [sid for sid, _ in stage_samples]
    capacities = [stage['max_cap'] for _, stage in stage_samples]
     
    return [         
        {
            'fest_id': fest['id'],
            'stage_id': s_id,
            'name': fake.word() + 'Event',
            'duration': random.randint(2,9),     #1 to 3 performances per event
            'date_time': start_datetime + timedelta(i),
            'max_cap':capacities[i]
        }
        for i,s_id in enumerate(stages_id)
    ]
event_keys = ['fest_id','stage_id','name','duration']

def generate_artists(id):
    stage_name =  fake.prefix_nonbinary() + ' ' + fake.language_name()
    return{
        'id': id,
        'first_name': fake.first_name(),
        'last_name': fake.last_name(),
        'stage_name': stage_name,
        'dob': fake.passport_dob(),
        'site':fake.url(),
        'ig': '@'+ stage_name.replace(' ','_')
    }
artists = [generate_artists(id) for id in range(1,artist_num+1)]
artist_keys = ['id', 'first_name', 'last_name', 'stage_name', 'dob', 'site', 'ig']

def split_event_into_performances(duration_hours):
    duration_minutes = duration_hours * 60
    performances = []
    time_left = duration_minutes
    delt = 0
    while time_left - 5 >= 30:  # Assume minimum performance length is 30 mins
        # Pick performance length (max 180, but ≤ time_left)
        perf_duration = min(random.randint(30, 180), time_left - 5)
        time_left -= perf_duration

        # Add a break if enough time remains
        if time_left >= 5:
            break_duration = min(random.randint(5, 30), time_left)
            performances.append((perf_duration,break_duration,delt))  # Use negative for breaks
            delt += perf_duration + break_duration
            time_left -= break_duration
        else:
            break  # No more time for a break

    return performances

perf_keys = ['event_id','stage_id','perf_typ_id','start_time','duration_minutes','break_duration_minutes','artist_id']
def generate_performances(event_id,event):
    return [
        {
            'event_id': event_id,
            'stage_id': event['stage_id'],              #stage_id is redundunt
            'perf_typ_id': random.randint(1,3),
            'start_time': event['date_time'] + timedelta(minutes=delt),
            'duration_minutes': p_min,
            'break_duration_minutes': b_min,
            'artist_id': random.randint(1,artist_num)
        }
        for p_min,b_min,delt in split_event_into_performances(event['duration'])
    ]

###     IMPORTANT: TURN TIME INTERVALS FROM INT TO TIME TYPE 
###                BOTH IN INSERT.SQL AND HERE, MAKE SURE USE CORECT FORMAT FOR INSEARTING
    
def generate_stage_eq(s_id,eq_id):
    return{
        'stage_id': s_id,
        'equipment_id':eq_id,
        'quantity': random.randint(1,50)
    }
stage_eq_keys = ['stage_id','equipment_id','quantity']

def genrate_rating(v_id,p_id):
    return{
        'v_id': v_id,
        'p_id':p_id,
        'ai': random.randint(1,5),
        'si': random.randint(1,5),
        'sp': random.randint(1,5),
        'org': random.randint(1,5),
        'ov_imp': random.randint(1,5),
    }
rat_keys= ['v_id','p_id','ai','si','sp','org','ov_imp']

t_category = ['general','VIP','backstage']   ##VIP must be max 10% of stage capacity, needs dictionary ev_id->max_capacity
def generate_ticket(v_id,ev_id,p_date,stop_vip=False):
    i,_ = random.choice(list(enumerate(t_category)))
    if (stop_vip): i = 0
    return{
        'v_id': v_id,
        'ev_id': ev_id,
        'p_date': p_date,
        'cost': random.randint(50*(i*3+1),200*(i*2+1)),
        'meth_id': random.randint(1,3),
        'EAN': fake.ean13(),
        'cat': i+1,
        'status': random.randint(1,2)
    }
tick_keys = ['v_id','ev_id','p_date','cost','meth_id','EAN','cat','status']
#Genarate dictionaries
ticket_category=[
    {
        'id': i+1,
        'name': t_category[i]
    } for i in range(3) 
]
ticket_staus=[ { 'id':i+1,'name':n}for i,n in enumerate(['deactivated','activated'])]

continents = []
c = ['Asia','Africa','North America','South America','Europe','Oceania']
for i in range (6):
    continents.append({
        'id': i+1,
        'name': c[i]
    })

performance_type = []
p = ['warm up', 'headline', 'Special guest']
for i in range (3):
    performance_type.append(
        {
            'id': i+1,
            'type':p[i]
        }
    )
exxp_level= []
l = ['intern', 'novice', 'intermediate','experienced','super saiyan god']
for i in range (5):
    exxp_level.append(
        {
            'id': i+1,
            'level': l[i]
        }
    )
pers_role= []
r = ['technical', 'security', 'assistant']
for i in range (3):
    pers_role.append(
        {
            'id': i+1,
            'role': r[i]
        }
    )
Personnel_num = 1000
personnel = [
    {   
        'id': id,
        'name': fake.name(),
        'age':random.randint(18,55),
        'role':random.randint(1,3),               
        'level':random.randint(1,5)
    } for id in range(1,Personnel_num+1)
]
pers_keys = ['id','name','age','role','level']
Eq = [
    "Microphones",
    "Mic stands",
    "Stage monitors",
    "Main PA speakers",
    "Mixer (audio console)",
    "Instrument amplifiers",
    "Drum kit",
    "DI boxes",
    "Cables (XLR, instrument, power)",
    "Power strips and extension cords",
    "Lighting rig (spotlights, floodlights, effects)",
    "Lighting control board",
    "Stage risers",
    "Backdrop or stage curtain",
    "Music stands",
    "Stage snakes (multicore cables)",
    "Monitor mixing system",
    "In-ear monitor system",
    "Laptop or playback device",
    "Fog or haze machine"
]

equipment = [{
    'id': i+1,
    'name': name,
    'desc': fake.sentence()
}for i,name in enumerate(Eq)
]
methods = ['Credit Card', 'Debit Card', 'Bank Transfer']
p_meth = [
    {
        'id': m_id+1,
        'name': name
    } for m_id,name in enumerate(methods)
]
visitor_num = 1000
visitor = [
    {
        'fn':fake.first_name(),
        'ln':fake.last_name(),
        'email':fake.ascii_email(),
        'phone':fake.bothify(text='69########'),
        'age':random.randint(14,90)
    }for _ in range (visitor_num)
]
vis_keys=['fn','ln','email','phone','age']
years = [2027,2026,2025,2024,2023,2022,2021,2020,2019,2018,2017,2016,2015]
locations = [generate_locations(continents) for _ in range(loc_num)]
festivals = [genarate_festivals(id,years[id-1]) for id in range(1,1+ fest_num)]
stages = [genarate_stage() for _ in range(stage_num)]
events = [event for fest in festivals for event in generate_events(fest,stages)]
performances = [perf for id,event in enumerate(events) for perf in generate_performances(id+1,event)]
stage_equipment = []
for s_id in range(1,stage_num+1):
    for eq_id,_ in enumerate(Eq):
        if(random.random() <0.33): 
            stage_equipment.append(generate_stage_eq(s_id,eq_id+1))
ratings=[]
tickets=[]
ev_vis=[]
for e_id,event in enumerate(events):
    s_date = event['date_time']
    cap = event['max_cap']
    vip_count=0
    stop_vip = False
    for v_id in range(1,visitor_num+1):
        if (random.random() < 0.1): 
            ticket = generate_ticket(v_id,e_id+1,s_date - timedelta(random.randint(15,100)),stop_vip)
            tickets.append(ticket)
            ev_vis.append((e_id+1,v_id))
            if (ticket['status']==2): vip_count+=1
            if(vip_count+1 >= 0.1*cap): stop_vip = True
#make ticket, if ticket[status] is vip then vip_count+=1 if vip_count > 0,1*max_cap -1 don't generate more vip tickets

for p_id,p in enumerate(performances):
    for ev_id,v_id in ev_vis:
        if ((p['event_id'] == ev_id) and random.random()<0.4): ratings.append(genrate_rating(v_id,p_id+1))

#Personnel-Performance
perf_pers = []
for p_id,_ in enumerate(performances):
    cap = 2000
    sec_count = 0
    sup_count = 0
    for pers_id,pers in enumerate(personnel):
        if (random.random()<0.1): perf_pers.append({
            'p_id': p_id+1,               
            'pers_id': pers_id+1          #### minimum 5%security(1), 2%support(2), Make a dictionary event_id->max_capacity
        })
        elif((pers['role']==2 and sec_count < 0.05*cap)):
            perf_pers.append({
            'p_id': p_id+1,               
            'pers_id': pers_id+1
            })
            sec_count+=1
        elif((pers['role']==3 and sup_count < 0.02*cap)):
            perf_pers.append({
            'p_id': p_id+1,               
            'pers_id': pers_id+1
            })
            sup_count+=1
        
        

st = ['available', 'sold']
res_status = [
    {
        'id':i+1,
        'name':s
    }for i,s in enumerate(st)
]

Resale_Seller_Queue = [
    {
        't_id':i+1,
        'Listed_Date': t['p_date'] + timedelta(days=random.randint(1,13)),
        'Sale_Status_ID': random.randint(1,2)
    }for i,t in enumerate(tickets) if (t['status'] == 1 and random.random()<0.05)
]
Resale_Seller_Queue_keys = ['t_id','Listed_Date','Sale_Status_ID']

buyers_visitors = [
    {
        'fn':fake.first_name(),
        'ln':fake.last_name(),
        'email':fake.ascii_email(),
        'phone':fake.bothify(text='69########'),
        'age':random.randint(14,90)
    }for _ in range (10) # apo id 1001 to 1011
]

Resale_Buyer_Interest = [
    (
        lambda eid, ev: {
            'v_id': id + 1001,
            'e_id': eid + 1,
            'c_id': random.randint(1, 3),
            'date': ev['date_time'] - timedelta(days=random.randint(1, 20))
        }
    )(*random.choice(list(enumerate(events))))
    for id, _ in enumerate(buyers_visitors)
]
Resale_Buyer_Interest_keys = ['v_id','e_id','c_id','date']

#some bands
bands = [
    {
        'Band_Name':fake.word().capitalize,
        'Formation_Date': fake.date(),
        'Website':fake.url()
    }for _ in range (10)
]
artist_band = []
a=[]
for b_id,_  in enumerate(bands):
    for _ in range(5):
        a_id = fake.random_int(1,artist_num)
        if a_id not in a:
            a.append(a_id)
            artist_band.append({
                'Artist_ID':a_id,
                'Band_ID': b_id+1
            })
#write to .sql file

with open("load.sql", "w") as load_sql:
    load_sql.write('use musicfestival;\n')
    for rs in res_status:
        load_sql.write(
            generate_sql(
                'Resale_Status',
                ['Status_ID','Status_Name'],
                rs,
                ['id','name']
            )
        )

    for ts in ticket_staus:
        load_sql.write(
            generate_sql(
                'Ticket_Status',
                ['Status_ID','Status_Name'],
                ts,
                ['id','name']
            ) 
        )
    for tc in ticket_category:
        load_sql.write(
            generate_sql
            (
                'Ticket_Category',
                ['Category_ID','Category_Name'],
                tc,
                ['id','name']
            )
        )
    for lev in exxp_level:
        load_sql.write(
            generate_sql
            ('Experience_Level',
             ['Level_ID','Level_Name'],
             lev,
             ['id','level']
        )
    )
    for v in visitor:
        load_sql.write(
            generate_sql
            (
                'Visitor',
                ['First_Name','Last_Name','Email','Phone_Number','Age'],
                v,
                vis_keys
            )
        )    
    
    for pm in p_meth:
        load_sql.write(
            generate_sql(
                'Payment_Method',
                ['Method_id','Method_Name'],
                pm,
                ['id','name']
            )
        )

    for eq in equipment:
        load_sql.write(
            generate_sql
            (
                'Equipment',
                ['Equipment_id','Name','Description'],
                eq,
                ['id','name','desc']
            )
        )
    
    
    for role in pers_role:
        load_sql.write(
            generate_sql
            ('Personnel_Role',
             ['Role_ID','Personnel_Role'],
             role,
             ['id','role']
        )
    )

    for cont in continents:
        load_sql.write(f"INSERT INTO Continent\n "
        f"(Continent_ID, Continent_Name)\n"
        f"VALUES\n"
        f"({cont['id']}, '{cont['name']}')\n"
        f";\n")

    for loc in locations:
        load_sql.write(f"INSERT INTO Location\n "
        f"(Location_Address, Longitude, Latitude, City, Country, Continent_ID)\n"
        f"VALUES\n"
        f"('{loc['address']}', {loc['long']}, {loc['lat']}, '{loc['city']}', '{sql_str(loc['country'])}', {loc['continent_id']})\n"
        f";\n") 
    
    for fest in festivals:
        load_sql.write(f"INSERT INTO Festival\n "
        f"(Name, Start_Date, End_Date, Location_ID)\n"
        f"VALUES\n"
        f"('{fest['name']}','{fest['start_date']}','{fest['end_date']}',{fest['location_id']})\n"
        f";\n")

    for stage in stages:
        load_sql.write(
            generate_sql('Stage',
                         ['Name','Description','Maximum_Capacity','Technical_Requirements'],
                         stage,
                         ['name','desc','max_cap','tech_req']
            )
       )
        
    for s_eq in stage_equipment:
        load_sql.write(
            generate_sql
            (
                'StageEquipment',
                ['Stage_ID,Equipment_ID','Quantity'],
                s_eq,
                stage_eq_keys
            )
        )
        
    for event in events:
        load_sql.write(
            generate_sql(
                'Event',
                ['Festival_ID','Stage_ID','Event_Name','Duration'],
                event,
                event_keys
            )
        )

    for artist in artists:
        load_sql.write(
            generate_sql(
                'Artist',
                ['Artist_ID', 'First_Name','Last_Name','Stage_Name','Date_of_Birth','Website','Instagram'],
                artist,
                artist_keys
            )
        )
    
    for pt in performance_type:
        load_sql.write(
            generate_sql(
                'Performance_Type',
                ['Performance_Type_ID','Performance_Type'],
                pt,
                ['id','type']
            )
        )

    for p in performances:
        load_sql.write(
            generate_sql(
                'Performance',
                ['Event_ID','Stage_ID','Performance_Type_ID','Start_Time','Duration','Break_Duration','Artist_ID'],
                p,
                perf_keys
           )
        )
    for t in tickets:
        load_sql.write(
            generate_sql(
                'Ticket',
                ['Visitor_ID','Event_ID','Purchase_Date','Cost','Payment_Method_ID',
                 'EAN_Code','Category_ID','Ticket_Status_ID'],
                t,
                tick_keys
            )
        )
    for r in ratings:
        load_sql.write(
            generate_sql(
                'Rating',
                ['Visitor_ID','Performance_ID','Artist_Interpretation',
                 'Sound_Lighting','Stage_Presence','Organization','Overall_Impression'],
                 r,
                 rat_keys
            )
        )

    for p in personnel:
        load_sql.write(
            generate_sql(
                'Personnel',
                ['Personnel_ID','Personnel_Name','Age','Personnel_Role_ID', 'Experience_Level_ID'],
                p,
                pers_keys
            )
        )
    for pp in perf_pers:
        load_sql.write(
            generate_sql(
                'PerformancePersonnel',
                ['Performance_ID','Personnel_ID'],
                pp,
                ['p_id','pers_id']
            )
        )

    for rsq in Resale_Seller_Queue:
        load_sql.write(
            generate_sql(
                'Resale_Seller_Queue',
                ['Ticket_ID','Listed_Date','Sale_Status_ID'],
                rsq,
                Resale_Seller_Queue_keys
            )
        )
    for v in buyers_visitors:
        load_sql.write(
            generate_sql
            (
                'Visitor',
                ['First_Name','Last_Name','Email','Phone_Number','Age'],
                v,
                vis_keys
            )
        ) 
    for rbi in Resale_Buyer_Interest:
        load_sql.write(
            generate_sql(
                'Resale_Buyer_Interest',
                ['Visitor_ID','Event_ID','Category_ID','Interest_Date'],
                rbi,
                Resale_Buyer_Interest_keys    
           )
        )

    for b in bands:
        load_sql.write(
            generate_sql(
                'Band',
                ['Band_Name','Formation_Date','Website'],
                b,
                ['Band_Name','Formation_Date','Website']
            )
        )
    for ab in artist_band:
        load_sql.write(
            generate_sql(
                'ArtistBand',
                ['Artist_ID','Band_ID'],
                ab,
                ['Artist_ID','Band_ID']
            )
        )