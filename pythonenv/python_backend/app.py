import sys
import logging
import rds_config
import pymysql

RUNTEST = False
# RUNTEST = True
NLOCS = 5
DEFAULTLOCNUMBER = 4
SUCCESS = {'Success': True}
FAILURE = {'Success': False}

rds_host = "burrowedtime.c221frlbtuue.us-east-2.rds.amazonaws.com"
name = rds_config.db_username
password = rds_config.db_password
db_name = rds_config.db_name

logger = logging.getLogger()
logger.setLevel(logging.INFO)

selectstring = \
"""SELECT users.userid, users.name, locations.loc_number, groups.revision
FROM locations
INNER JOIN users ON locations.userid=users.userid
INNER JOIN groups ON locations.groupid=groups.groupid
{where};"""
# """SELECT users.userid, users.name, groups.groupid, groups.groupname, locations.loc_number, groups.revision

get_locations_string = \
"SELECT {loc_nums}\n".format(loc_nums=", ".join(['loc'+str(i) for i in range(0, NLOCS)]))\
 + """FROM groups
WHERE groupid = {groupid};"""

get_max_userid_string = \
"""SELECT MAX(userid)
FROM users;"""

get_max_groupid_string = \
"""SELECT MAX(groupid)
FROM groups;"""

get_user_from_phonenumber_string = \
"""SELECT *
FROM users
WHERE phonenumber = {phonenumber};"""

add_user_string = \
"""INSERT INTO `burrowedtime`.`users`
(`userid`,
`name`,
`phonenumber`)
VALUES
({userid},
'{username}',
{phonenumber});"""

add_group_string = \
"""INSERT INTO `burrowedtime`.`groups`
(`groupid`,
`groupname`,
{loc_nums}\n)""".format(loc_nums=", ".join(["`loc"+str(i)+"`" for i in range(0, NLOCS)]))\
 + """VALUES
({groupid},
'{groupname}',
{loc_names});"""

change_loc_name_string = \
"""UPDATE `burrowedtime`.`groups`
SET {setstring} , `revision` = `revision` + 1
WHERE `groupid` = {groupid};"""


set_location_string = \
"""INSERT INTO `burrowedtime`.`locations`
(`groupid`,
`userid`,
`loc_number`)
VALUES
({groupid},
{userid},
{loc_number});"""


update_location_string = \
"""UPDATE `burrowedtime`.`locations`
SET
`loc_number` = {loc_number}
WHERE `groupid` = {groupid} AND `userid` = {userid};"""

leave_group_string = \
"""DELETE FROM `burrowedtime`.`locations`
WHERE `groupid` = {groupid} AND `userid` = {userid};"""

delete_group_string = \
"""DELETE FROM `burrowedtime`.`groups`
WHERE `groupid` = {groupid};"""


class InsufficientInformationException(Exception):
    def __init__(self, message=""):
        super(InsufficientInformationException, self).__init__("ERROR: Insufficient information - "+message)


def guarantee_exists(keys):
    def guarantee_exists_decorator(function):
        def new_function(*args, **kwargs):
            for key in keys:
                if key not in args[0]:
                    raise InsufficientInformationException(key+" not provided")
            return function(*args, **kwargs)

        return new_function

    return guarantee_exists_decorator


def guarantee_not_empty(keys):
    def guarantee_not_empty_decorator(function):
        @guarantee_exists(keys)
        def new_function(*args, **kwargs):
            for key in keys:
                if not args[0][key]:
                    raise InsufficientInformationException(key+" not provided")
            return function(*args, **kwargs)
        return new_function
    return guarantee_not_empty_decorator


def add_success(json):
    json.update(SUCCESS)
    return json


def add_failure(json):
    json.update(FAILURE)
    return json


def tab_tup_to_list(tuple_table):
    return [list(row) for row in tuple_table]


def test(event, context):
    logger.info("event: " + repr(event) + "\n")
    logger.info("context: " + repr(context) + "\n")

    # logger.error(str(event.values()))
    # logger.error(str(event['queryStringParameters']['userid']))

    return "event: "+repr(event)+"\ncontext: "+repr(context)


def connect():
    try:
        conn = pymysql.connect(rds_host, user=name, passwd=password, db=db_name, connect_timeout=5)
    except Exception as e:
        print("connection failed")
        logger.error("ERROR: Unexpected error: Could not connect to MySql instance -- "+str(e))
        sys.exit()

    return conn


def get_user_by_phonenumber(phonenumber):
    conn = connect()
    with conn.cursor() as cur:
        cur.execute(get_user_from_phonenumber_string.format(phonenumber=phonenumber))
        rows = tab_tup_to_list(cur.fetchall())
    conn.commit()
    conn.close()
    if rows:
        return rows[0]
    else:
        return list()


def get_location_names(groupid):
    if groupid is None or not str(groupid).isdigit():
        return list()
    conn = connect()
    with conn.cursor() as cur:
        cur.execute(get_locations_string.format(groupid=groupid))
        rows = tab_tup_to_list(cur.fetchall())
    conn.commit()
    conn.close()
    if rows:
        return rows[0]
    else:
        return list()


def get_location(userid=None, groupid=None):
    conn = connect()
    with conn.cursor() as cur:
        wherestring = "WHERE "
        if userid is not None and str(userid).isdigit():
            wherestring += "users.userid = {userid}".format(userid=userid)
            if groupid is not None and str(groupid).isdigit():
                wherestring += " AND "
                wherestring += "groups.groupid = {groupid}".format(groupid=groupid)

        elif groupid is not None and str(groupid).isdigit():
            wherestring += "groups.groupid = {groupid}".format(groupid=groupid)

        else:
            return list()

        cur.execute(selectstring.format(where=wherestring))
        rows = tab_tup_to_list(cur.fetchall())

    conn.commit()
    conn.close()
    return rows


def add_user(username, phonenumber):
    conn = connect()
    with conn.cursor() as cur:
        cur.execute(get_user_from_phonenumber_string.format(phonenumber=phonenumber))
        if cur.rowcount > 0:
            return -1

        cur.execute(get_max_userid_string)
        userid = cur.fetchall()[0][0] + 1
        cur.execute(add_user_string.format(userid=userid, username=username, phonenumber=phonenumber))

    conn.commit()
    conn.close()
    return userid


def create_group(groupname, locs):
    if len(locs) != NLOCS:
        return -1

    conn = connect()
    with conn.cursor() as cur:
        cur.execute(get_max_groupid_string.format())
        groupid = cur.fetchall()[0][0] + 1
        cur.execute(add_group_string.format(groupid=groupid, groupname=groupname,
                                            loc_names=", ".join(["'"+loc+"'" for loc in locs])))

    conn.commit()
    conn.close()
    return groupid


def change_location_names(groupid, loc_dict):
    for loc_num in loc_dict.keys():
        if not str(loc_num).isdigit():
            return -1
    conn = connect()
    with conn.cursor() as cur:
        setstring=", ".join(["`loc"+str(loc_num)+"` = '"+str(loc_dict[loc_num])+"'" for loc_num in loc_dict.keys()])
        # print(setstring)
        cur.execute(change_loc_name_string.format(groupid=groupid, setstring=setstring))
    conn.commit()
    conn.close()
    return 0


def set_location(userid, groupid, loc_number):
    conn = connect()
    with conn.cursor() as cur:
        if get_location(userid, groupid):
            cur.execute(update_location_string.format(groupid=groupid, userid=userid, loc_number=loc_number))
        else:
            cur.execute(set_location_string.format(groupid=groupid, userid=userid, loc_number=loc_number))

    conn.commit()
    conn.close()
    return 0


def join_group(userid, groupid):
    if get_location(userid, groupid):
        # user is already in group
        # TODO: Change this to an exception
        return {"Message": "Already in group.", 'Success': False}
    return set_location(userid, groupid, DEFAULTLOCNUMBER)


def leave_group(userid, groupid):
    conn = connect()
    with conn.cursor() as cur:
        cur.execute(leave_group_string.format(groupid=groupid, userid=userid))
        conn.commit()
        if not get_location(groupid=groupid):
            # delete group if everyone has left
            cur.execute(delete_group_string.format(groupid=groupid))
    conn.commit()
    conn.close()
    return 0

# TODO: figure out how to actually send back errors
# TODO: sort out edge cases, especially empty entries


def process_get_location_request(event, context):
    try:
        userid = event['userid']
    except KeyError:
        userid = None
    try:
        groupid = event['groupid']
    except KeyError:
        groupid = None

    loc_info = get_location(userid, groupid)
    if not loc_info:
        return add_failure({"Message": "ERROR: Lookup failed. Nothing matches query parameters."})

    response = {row[0]: {'username': row[1], 'loc_number': row[2]} for row in loc_info}
    response['revision'] = loc_info[0][3]

    return add_success(response)


@guarantee_not_empty(['groupid'])
def process_get_location_names_request(event, context):
    groupid = event['groupid']

    return add_success({'locations': get_location_names(groupid)})


@guarantee_not_empty(['username', 'phonenumber'])
def process_add_user_request(event, context):
    username = event['username']
    phonenumber = event['phonenumber']

    userid = add_user(username, phonenumber)

    if userid == -1:
        raise Exception('ERROR: User add failed. Phone number already registered.')
    else:
        return add_success({'userid': userid})


@guarantee_not_empty(['userid', 'groupname', 'locs'])
def process_create_group_request(event, context):
    userid = event['userid']
    groupname = event['groupname']
    locs = event['locs']

    groupid = create_group(groupname, locs)
    join_group(userid, groupid)
    if groupid == -1:
        raise Exception('ERROR: Group creation failed. Check information and try again.')
    else:
        return add_success({'groupid': groupid})


@guarantee_not_empty(['groupid', 'loc_dict'])
def process_change_location_names_request(event, context):
    groupid = event['groupid']
    loc_dict = event['loc_dict']

    status = change_location_names(groupid, loc_dict)
    if status == -1:
        raise Exception('ERROR: Could not process request.')
    else:
        return SUCCESS


@guarantee_not_empty(['userid', 'groupid', 'loc_number'])
def process_set_location_request(event, context):
    userid = event['userid']
    groupid = event['groupid']
    loc_number = event['loc_number']

    set_location(userid, groupid, loc_number)
    return SUCCESS


@guarantee_not_empty(['userid', 'groupid'])
def process_join_group_request(event, context):
    userid = event['userid']
    groupid = event['groupid']

    message = join_group(userid, groupid)
    if message:
        return message
    return SUCCESS


@guarantee_not_empty(['userid', 'groupid'])
def process_leave_group_request(event, context):
    userid = event['userid']
    groupid = event['groupid']

    leave_group(userid, groupid)
    return SUCCESS


@guarantee_not_empty(['phonenumber'])
def process_get_user_by_phonenumber_request(event, context):
    data = get_user_by_phonenumber(event['phonenumber'])

    if data:
        return add_success({'userid': data[0], 'username': data[1]})
    else:
        return add_failure({'userid': -1, 'username': ''})


if RUNTEST:
    # revision is for keeping track if the location names have been changed
    print(get_location(1, 10))
    print(get_location(groupid=10))
    print(get_location())
    print(add_user('user3', '1231231236'))

    print(change_location_names(10, {1: "home", 3: "traveling", 0: "despair"}))
    print(get_location_names(10))
    print(get_location_names(0))
    print(change_location_names(10, {1: "Sudikoff", 3: "nowhere", 0: "hope"}))
    print(get_location_names(10))

    #print(get_location_names(13))
    join_group(1, 10)
    print(get_location(1, 10))
    set_location(1, 10, 1)
    print(get_location(1, 10))
    print(process_leave_group_request({'userid': 1, 'groupid': 10}, "usercontext"))
    print(process_get_location_request({'userid': '1', 'groupid': '10'}, "useless_context"))
    print(process_get_location_request({'groupid': '10'}, "useless_context"))
    print(process_get_location_names_request({'groupid': '10'}, "useless_context"))

    print(process_get_user_by_phonenumber_request({'phonenumber': 1234567890}, "useless_context"))

    print(process_create_group_request({'userid': 1, 'groupname': 'group3',
                                        'locs': ['home', 'work', 'gym', 'traveling', 'mortal peril']},
                                       "useless_context"))
    print(process_join_group_request({'userid': 2, 'groupid': 15}, "useless_context"))
    print(process_get_location_request({'groupid': 15}, "useless_context"))
    print(process_leave_group_request({'userid': '1', 'groupid': 15}, "useless_context"))
    print(process_leave_group_request({'userid': '2', 'groupid': 15}, "useless_context"))
    print(process_get_location_request({'groupid': 15}, "useless_context"))

