//Convert {string[], string[][]} into object
function transformData(data) {
    const { columns, rows } = data;

    if (!columns || !rows || rows.length === 0) {
        return null; // Handle empty or invalid data
    }

    // Map each row to an object
    const result = rows.map(row => {
        const rowObject = {};
        columns.forEach((column, index) => {
            rowObject[column] = row[index];
        });
        return rowObject;
    });

    return result;
}

module.exports = {
    transformData
}