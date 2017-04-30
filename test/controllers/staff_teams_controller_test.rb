require 'test_helper'

class StaffTeamsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @staff_team = staff_teams(:one)
  end

  test "should get index" do
    get staff_teams_url
    assert_response :success
  end

  test "should get new" do
    get new_staff_team_url
    assert_response :success
  end

  test "should create staff_team" do
    assert_difference('StaffTeam.count') do
      post staff_teams_url, params: { staff_team: { name: @staff_team.name } }
    end

    assert_redirected_to staff_team_url(StaffTeam.last)
  end

  test "should show staff_team" do
    get staff_team_url(@staff_team)
    assert_response :success
  end

  test "should get edit" do
    get edit_staff_team_url(@staff_team)
    assert_response :success
  end

  test "should update staff_team" do
    patch staff_team_url(@staff_team), params: { staff_team: { name: @staff_team.name } }
    assert_redirected_to staff_team_url(@staff_team)
  end

  test "should destroy staff_team" do
    assert_difference('StaffTeam.count', -1) do
      delete staff_team_url(@staff_team)
    end

    assert_redirected_to staff_teams_url
  end
end
