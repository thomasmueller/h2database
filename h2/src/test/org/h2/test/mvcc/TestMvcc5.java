/*
 * Copyright 2004-2020 H2 Group. Multiple-Licensed under the MPL 2.0,
 * and the EPL 1.0 (https://h2database.com/html/license.html).
 * Initial Developer: H2 Group
 */
package org.h2.test.mvcc;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import org.h2.test.TestBase;
import org.h2.test.TestDb;

/**
 * Additional MVCC (multi version concurrency) test cases.
 */
public class TestMvcc5 extends TestDb {

    /**
     * Run just this test.
     *
     * @param a ignored
     */
    public static void main(String... a) throws Exception {
        TestBase test = TestBase.createCaller().init();
        test.config.lockTimeout = 20000;
        test.config.memory = true;
        test.test();
    }

    @Override
    public boolean isEnabled() {
        if (config.networked || !config.mvStore) {
            return false;
        }
        return true;
    }

    @Override
    public void test() throws SQLException {
        testSelectAndUpdateConcurrency();
    }

    /** @see https://stackoverflow.com/questions/59441183 */
    private void testSelectAndUpdateConcurrency() throws SQLException {
        deleteDb("mvcc5");
        int level = Connection.TRANSACTION_REPEATABLE_READ;
        try (
                Connection setup = getConnection("mvcc5");
                Connection c1 = getConnection("mvcc5");
                Connection c2 = getConnection("mvcc5");
            ) {
            try (Statement s = setup.createStatement()) {
                s.executeUpdate("CREATE TABLE test ("
                        + "id INT NOT NULL PRIMARY KEY, "
                        + "val INT NOT NULL)");
                s.executeUpdate("INSERT INTO test (id, val) VALUES (1, 10)");
            }

            c1.setTransactionIsolation(level);
            c1.setAutoCommit(false);
            c2.setTransactionIsolation(level);
            c2.setAutoCommit(false);

            // Session A
            PreparedStatement ps1 = c1.prepareStatement(
                    "SELECT val FROM test WHERE id = ?");
            ps1.setInt(1, 1);
            ResultSet rs1 = ps1.executeQuery();
            rs1.next();
            assertEquals(10, rs1.getInt("val"));

            // Session B
            PreparedStatement ps2 = c2.prepareStatement(
                    "SELECT val FROM test WHERE id = ?");
            ps2.setInt(1, 1);
            ResultSet rs2 = ps2.executeQuery();
            rs2.next();
            assertEquals(10, rs2.getInt("val"));

            // Session A
            PreparedStatement psu1 = c1.prepareStatement(
                    "UPDATE test SET val = val + ? WHERE id = ?");
            psu1.setInt(1, 2);
            psu1.setInt(2, 1);
            assertEquals(1, psu1.executeUpdate());
            rs1 = ps1.executeQuery();
            rs1.next();
            assertEquals(12, rs1.getInt("val"));
            c1.commit();

            // Session B
            rs2 = ps2.executeQuery();
            rs2.next();
            // Here we get the expected result because Session B have an isolated 
            // copy of row id = 1, i.e. the commit from Session A is NOT visible here
            assertEquals(10, rs2.getInt("val"));

            // Session B
            PreparedStatement psu2 = c2.prepareStatement(
                    "UPDATE test SET val = val + ? WHERE id = ?");
            psu2.setInt(1, 3);
            psu2.setInt(2, 1);
            // According to this video https://www.youtube.com/watch?v=sxabCqWsFHg
            // about MVCC (at 15'00"), this update should be rejected.
            assertEquals(1, psu2.executeUpdate());

            // Session B
            rs2 = ps2.executeQuery();
            rs2.next();
            // 10 if update is really rejected
            assertEquals(15, rs2.getInt("val"));
            c2.rollback();
        }
    }
}
