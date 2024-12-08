const oracledb = require("oracledb");

const DB = {
    USERNAME: 'lulo97',
    PASSWORD: '123',
    SERVICE: 'xe',
    CLIENT_LATH: 'C:\\oracle\\instantclient_11_2',
}

const URL = 'localhost:1521'

const config = {
    user: DB.USERNAME,
    password: DB.PASSWORD,
    connectString: `${URL}/${DB.SERVICE}`
}

async function getConnection() {
    oracledb.initOracleClient({ libDir: DB.CLIENT_LATH });
    return await oracledb.getConnection(config);
}

async function executeProcedure(
    action,
    id = null,
    name = null,
    description = null
) {
    let connection;
    try {
        connection = await getConnection();

        const bindParams = {
            p_refcursor: { dir: oracledb.BIND_OUT, type: oracledb.CURSOR },
            p_id: id,
            p_name: name,
            p_description: description,
            p_action: action,
        };

        const result = await connection.execute(
            `BEGIN prc_crud_todos(:p_refcursor, :p_id, :p_name, :p_description, :p_action); END;`,
            bindParams
        );

        const resultSet = result.outBinds.p_refcursor;
        const rows = await resultSet.getRows(); 

        const columns = result.outBinds.p_refcursor.metaData.map(
            (ele) => ele.name
        );
        await resultSet.close(); 
        return { columns, rows };
    } catch (error) {
        console.error("Error executing procedure:", error);
        throw error;
    } finally {
        if (connection) {
            try {
                await connection.close();
            } catch (closeErr) {
                console.error("Error closing connection:", closeErr);
            }
        }
    }
}

module.exports = {
    getConnection,
    executeProcedure
}